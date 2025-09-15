import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'todo_provider.dart';

part 'filter_provider.g.dart';

// Filter state for todos
@riverpod
class FilterState extends _$FilterState {
  @override
  TodoFilter build() {
    return const TodoFilter();
  }

  void updateFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void updateSort(String sortBy, bool ascending) {
    state = state.copyWith(sortBy: sortBy, sortAscending: ascending);
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateCategoryFilter(String? categoryId) {
    state = state.copyWith(filterByCategoryId: categoryId);
  }

  void reset() {
    state = const TodoFilter();
  }
}

// Filter model for managing todo filtering state
class TodoFilter {
  final String selectedFilter;
  final String sortBy;
  final bool sortAscending;
  final String searchQuery;
  final String? filterByCategoryId;

  const TodoFilter({
    this.selectedFilter = 'All',
    this.sortBy = 'Due Date',
    this.sortAscending = true,
    this.searchQuery = '',
    this.filterByCategoryId,
  });

  TodoFilter copyWith({
    String? selectedFilter,
    String? sortBy,
    bool? sortAscending,
    String? searchQuery,
    String? filterByCategoryId,
  }) {
    return TodoFilter(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      searchQuery: searchQuery ?? this.searchQuery,
      filterByCategoryId: filterByCategoryId ?? this.filterByCategoryId,
    );
  }
}

// Filtered todos provider that combines all filtering logic
@riverpod
Future<List<Todo>> filteredTodos(Ref ref) async {
  final todos = await ref.watch(todoNotifierProvider.future);
  final filter = ref.watch(filterStateProvider);

  List<Todo> filtered = todos;

  // Apply category filter first if specified
  if (filter.filterByCategoryId != null) {
    filtered = filtered.where((todo) => todo.categoryId == filter.filterByCategoryId).toList();
  }

  // Apply main filter
  switch (filter.selectedFilter) {
    case 'Today':
      // Include items due today but not overdue and not completed
      filtered = filtered.where((todo) {
        if (todo.dueDate == null) return false;
        return todo.isDueToday && !todo.isOverdue && !todo.isCompleted;
      }).toList();
      break;
    case 'This Week':
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1)); // Monday
      final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Sunday
      filtered = filtered.where((todo) {
        if (todo.dueDate == null) return false;
        final dueDay = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
        final inWeek = (dueDay.isAtSameMomentAs(startOfWeek) || dueDay.isAfter(startOfWeek)) &&
            (dueDay.isAtSameMomentAs(endOfWeek) || dueDay.isBefore(endOfWeek));
        return inWeek && !todo.isCompleted && !todo.isOverdue;
      }).toList();
      break;
    case 'Overdue':
      // Time-aware overdue using combined due date/time
      filtered = filtered.where((todo) => todo.isOverdue).toList();
      break;
    case 'Completed':
      filtered = filtered.where((todo) => todo.isCompleted).toList();
      break;
    case 'All':
    default:
      // No additional filtering
      break;
  }

  // Apply search filter
  if (filter.searchQuery.isNotEmpty) {
    final query = filter.searchQuery.toLowerCase();
    filtered = filtered.where((todo) {
      return todo.title.toLowerCase().contains(query) ||
             (todo.description?.toLowerCase().contains(query) ?? false) ||
             todo.subtasks.any((subtask) => subtask.title.toLowerCase().contains(query));
    }).toList();
  }

  // Apply sorting
  switch (filter.sortBy) {
    case 'Due Date':
      filtered.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return filter.sortAscending 
            ? a.dueDate!.compareTo(b.dueDate!)
            : b.dueDate!.compareTo(a.dueDate!);
      });
      break;
    case 'Priority':
      filtered.sort((a, b) {
        return filter.sortAscending
            ? a.priority.order.compareTo(b.priority.order)
            : b.priority.order.compareTo(a.priority.order);
      });
      break;
    case 'Created':
      filtered.sort((a, b) {
        return filter.sortAscending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt);
      });
      break;
    case 'Alphabetical':
      filtered.sort((a, b) {
        return filter.sortAscending
            ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
            : b.title.toLowerCase().compareTo(a.title.toLowerCase());
      });
      break;
  }

  return filtered;
}
