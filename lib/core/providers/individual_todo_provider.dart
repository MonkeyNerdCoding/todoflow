import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../models/priority.dart';
import '../../shared/utils/color_utils.dart';
import 'todo_provider.dart';
import 'category_provider.dart';


/// Provider for individual todo state to prevent cascading rebuilds
final individualTodoProvider = Provider.family<AsyncValue<Todo?>, String>((ref, todoId) {
  final todosAsync = ref.watch(todoNotifierProvider);
  
  return todosAsync.when(
    data: (todos) {
      try {
        final todo = todos.firstWhere((t) => t.id == todoId);
        return AsyncValue.data(todo);
      } catch (e) {
        return const AsyncValue.data(null);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for just the completion status of a specific todo - ultra optimized
final todoCompletionProvider = StateProvider.family<bool, String>((ref, todoId) {
  // Watch the specific todo's completion status
  final todoAsync = ref.watch(individualTodoProvider(todoId));
  return todoAsync.when(
    data: (todo) => todo?.isCompleted ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for todo display data that only updates when relevant fields change
final todoDisplayProvider = Provider.family<AsyncValue<TodoDisplayData>, String>((ref, todoId) {
  final todoAsync = ref.watch(individualTodoProvider(todoId));
  final categoriesAsync = ref.watch(categoryNotifierProvider);
  
  return todoAsync.when(
    data: (todo) {
      if (todo == null) {
        return const AsyncValue.error('Todo not found', StackTrace.empty);
      }
      
      return categoriesAsync.when(
        data: (categories) {
          try {
            final category = categories.firstWhere((c) => c.id == todo.categoryId);
            return AsyncValue.data(TodoDisplayData(
              id: todo.id,
              title: todo.title,
              description: todo.description,
              isCompleted: todo.isCompleted,
              dueDate: todo.dueDate,
              priority: todo.priority,
              categoryName: category.name,
              categoryColor: parseHexColor(category.colorCode),
            ));
          } catch (e) {
            return AsyncValue.data(TodoDisplayData(
              id: todo.id,
              title: todo.title,
              description: todo.description,
              isCompleted: todo.isCompleted,
              dueDate: todo.dueDate,
              priority: todo.priority,
              categoryName: 'Unknown',
              categoryColor: Colors.grey,
            ));
          }
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Toggle completion provider
final toggleTodoCompletionProvider = Provider.family<void Function(), String>((ref, todoId) {
  return () {
    final todoNotifier = ref.read(todoNotifierProvider.notifier);
    todoNotifier.toggleTodoCompletion(todoId);
  };
});

/// Lightweight data class for display purposes
class TodoDisplayData {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;
  final Priority priority;
  final String categoryName;
  final Color categoryColor;
  
  const TodoDisplayData({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    this.dueDate,
    required this.priority,
    required this.categoryName,
    required this.categoryColor,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoDisplayData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          isCompleted == other.isCompleted &&
          dueDate == other.dueDate &&
          priority == other.priority &&
          categoryName == other.categoryName &&
          categoryColor == other.categoryColor;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      isCompleted.hashCode ^
      dueDate.hashCode ^
      priority.hashCode ^
      categoryName.hashCode ^
      categoryColor.hashCode;
}
