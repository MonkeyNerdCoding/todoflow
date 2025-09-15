import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import '../models/models.dart';
import 'todo_provider.dart';
import 'category_provider.dart';
import '../../shared/constants/app_constants.dart';

part 'stats_provider.g.dart';

@riverpod
class TodoStats extends _$TodoStats {
  @override
  Future<TodoStatsData> build() async {
    // Watch the todo provider state directly for reactivity
    final todosAsync = ref.watch(todoNotifierProvider);
    final categoriesAsync = ref.watch(categoryNotifierProvider);
    
    return todosAsync.when(
      data: (todos) => categoriesAsync.when(
        data: (categories) => _calculateStats(todos, categories),
        loading: () => const TodoStatsData(
          todaysTasks: 0,
          completedToday: 0,
          pendingTasks: 0,
          overdueTasks: 0,
          activeCategories: 0,
        ),
        error: (_, __) => const TodoStatsData(
          todaysTasks: 0,
          completedToday: 0,
          pendingTasks: 0,
          overdueTasks: 0,
          activeCategories: 0,
        ),
      ),
      loading: () => const TodoStatsData(
        todaysTasks: 0,
        completedToday: 0,
        pendingTasks: 0,
        overdueTasks: 0,
        activeCategories: 0,
      ),
      error: (_, __) => const TodoStatsData(
        todaysTasks: 0,
        completedToday: 0,
        pendingTasks: 0,
        overdueTasks: 0,
        activeCategories: 0,
      ),
    );
  }
  
  TodoStatsData _calculateStats(List<Todo> todos, List<Category> categories) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calculate stats
    // Today's tasks: due today, not completed, and NOT overdue by time-of-day
    final todaysTodos = todos.where((todo) {
      if (todo.dueDate == null) return false;
      final dueDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
      return dueDate.isAtSameMomentAs(today) && !todo.isCompleted && !todo.isOverdue;
    }).length;
    
    final completedToday = todos.where((todo) {
      if (todo.completedAt == null) return false;
      final completedDate = DateTime(todo.completedAt!.year, todo.completedAt!.month, todo.completedAt!.day);
      return completedDate.isAtSameMomentAs(today);
    }).length;
    
    final pendingTodos = todos.where((todo) => !todo.isCompleted).length;
    
  // Overdue: anything past due now (includes earlier today by time-of-day)
  final overdueTodos = todos.where((todo) => todo.isOverdue).length;
    
    final activeCategories = categories.where((c) => c.isActive).length;
    
    return TodoStatsData(
      todaysTasks: todaysTodos,
      completedToday: completedToday,
      pendingTasks: pendingTodos,
      overdueTasks: overdueTodos,
      activeCategories: activeCategories,
    );
  }
}

// Recent todos provider
@riverpod
Future<List<Todo>> recentTodos(Ref ref) async {
  final todosAsync = ref.watch(todoNotifierProvider);
  
  return todosAsync.when(
    data: (todos) {
      // Get the most recent todos (by creation date)
      final sortedTodos = List<Todo>.from(todos);
      sortedTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Enforce a global limit for recent items
      return sortedTodos.take(AppConstants.recentTodosLimit).toList();
    },
    loading: () => <Todo>[],
    error: (_, __) => <Todo>[],
  );
}

@riverpod
Future<List<Todo>> searchTodos(Ref ref, String query) async {
  final todosAsync = ref.watch(todoNotifierProvider);
  
  return todosAsync.when(
    data: (todos) {
      if (query.isEmpty) return todos;
      
      final lowercaseQuery = query.toLowerCase();
      return todos.where((todo) {
        return todo.title.toLowerCase().contains(lowercaseQuery) ||
               (todo.description?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    },
    loading: () => <Todo>[],
    error: (_, __) => <Todo>[],
  );
}

// Data class for todo statistics
class TodoStatsData {
  final int todaysTasks;
  final int completedToday;
  final int pendingTasks;
  final int overdueTasks;
  final int activeCategories;
  
  const TodoStatsData({
    required this.todaysTasks,
    required this.completedToday,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.activeCategories,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoStatsData &&
          runtimeType == other.runtimeType &&
          todaysTasks == other.todaysTasks &&
          completedToday == other.completedToday &&
          pendingTasks == other.pendingTasks &&
          overdueTasks == other.overdueTasks &&
          activeCategories == other.activeCategories;

  @override
  int get hashCode =>
      todaysTasks.hashCode ^
      completedToday.hashCode ^
      pendingTasks.hashCode ^
      overdueTasks.hashCode ^
      activeCategories.hashCode;
}
