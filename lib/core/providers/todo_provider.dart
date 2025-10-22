import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/models.dart';
import 'category_provider.dart';

part 'todo_provider.g.dart';

@riverpod
class TodoNotifier extends _$TodoNotifier {
  @override
  Future<List<Todo>> build() async {
    return await _loadTodos();
  }

  Future<List<Todo>> _loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString('todos');
      
      if (todosJson != null) {
        final List<dynamic> todosList = json.decode(todosJson);
        return todosList.map((json) => Todo.fromJson(json)).toList();
      } else {
        // Create default todos if none exist
        final categories = await ref.read(categoryNotifierProvider.future);
        final defaultTodos = _createDefaultTodos(categories);
        await _saveTodos(defaultTodos);
        return defaultTodos;
      }
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  List<Todo> _createDefaultTodos(List<Category> categories) {
    if (categories.isEmpty) return [];

    final workCategory = categories.firstWhere((c) => c.name == 'Work', orElse: () => categories.first);
    final personalCategory = categories.firstWhere((c) => c.name == 'Personal', orElse: () => categories.first);
    final shoppingCategory = categories.firstWhere((c) => c.name == 'Shopping', orElse: () => categories.first);

    return [
      Todo.create(
        title: 'Complete project presentation',
        description: 'Prepare slides and demo for the quarterly review',
        categoryId: workCategory.id,
        priority: Priority.high,
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
      Todo.create(
        title: 'Submit monthly report',
        description: 'Submit the monthly progress report to management',
        categoryId: workCategory.id,
        priority: Priority.high,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Todo.create(
        title: 'Pay utility bills',
        description: 'Pay electricity and water bills',
        categoryId: personalCategory.id,
        priority: Priority.medium,
        dueDate: DateTime.now().subtract(const Duration(days: 1)), // Overdue
      ),
      Todo.create(
        title: 'Review team performance',
        description: 'Conduct monthly performance reviews',
        categoryId: workCategory.id,
        priority: Priority.medium,
        dueDate: DateTime.now().add(const Duration(days: 5)),
      ),
      Todo.create(
        title: 'Book dentist appointment',
        description: 'Schedule routine dental checkup',
        categoryId: personalCategory.id,
        priority: Priority.low,
        dueDate: DateTime.now().add(const Duration(days: 7)),
      ),
      Todo.create(
        title: 'Buy groceries',
        description: 'Weekly grocery shopping - milk, bread, fruits',
        categoryId: shoppingCategory.id,
        priority: Priority.medium,
        dueDate: DateTime.now().add(const Duration(days: 1)),
      ),
      Todo.create(
        title: 'Finish Flutter course',
        description: 'Complete the remaining modules on state management',
        categoryId: personalCategory.id,
        priority: Priority.high,
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ),
      Todo.create(
        title: 'Update resume',
        description: 'Add recent projects and skills',
        categoryId: workCategory.id,
        priority: Priority.low,
      ).markCompleted(), // Mark as completed for demo
    ];
  }

  Future<void> _saveTodos(List<Todo> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = json.encode(todos.map((t) => t.toJson()).toList());
      await prefs.setString('todos', todosJson);
    } catch (e) {
      // Handle save error silently for now
    }
  }

  Future<void> addTodo(Todo todo) async {
    final currentState = await future;
    final updatedTodos = [...currentState, todo];
    await _saveTodos(updatedTodos);
    state = AsyncValue.data(updatedTodos);
    
    // Update category task count
    await _updateCategoryTaskCount(todo.categoryId);
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    final currentState = await future;
    final updatedTodos = currentState.map((todo) {
      return todo.id == updatedTodo.id ? updatedTodo : todo;
    }).toList();
    await _saveTodos(updatedTodos);
    state = AsyncValue.data(updatedTodos);
    
    // Update category task count
    await _updateCategoryTaskCount(updatedTodo.categoryId);
  }

  Future<void> deleteTodo(String todoId) async {
    final currentState = await future;
    final todoToDelete = currentState.firstWhere((t) => t.id == todoId);
    final updatedTodos = currentState.where((todo) => todo.id != todoId).toList();
    await _saveTodos(updatedTodos);
    state = AsyncValue.data(updatedTodos);
    
    // Update category task count
    await _updateCategoryTaskCount(todoToDelete.categoryId);
  }

  Future<void> toggleTodoCompletion(String todoId) async {
    final currentState = await future;
    final updatedTodos = currentState.map((todo) {
      if (todo.id == todoId) {
        return todo.isCompleted ? todo.markPending() : todo.markCompleted();
      }
      return todo;
    }).toList();
    
    // Update state immediately for instant UI response
    await _saveTodos(updatedTodos);
    state = AsyncValue.data(updatedTodos);
    
    // Update category task count asynchronously to avoid blocking UI
    final updatedTodo = updatedTodos.firstWhere((t) => t.id == todoId);
    // Fire and forget - don't await to prevent blocking
    Future.microtask(() => _updateCategoryTaskCountAsync(updatedTodo.categoryId));
  }

  Future<void> toggleSubtaskCompletion(String todoId, String subtaskId) async {
    final currentState = await future;
    final updatedTodos = currentState.map((todo) {
      if (todo.id != todoId) return todo;
      final updatedSubtasks = todo.subtasks.map((s) {
        if (s.id == subtaskId) {
          return s.copyWith(isCompleted: !s.isCompleted);
        }
        return s;
      }).toList();
      return todo.copyWith(subtasks: updatedSubtasks);
    }).toList();

    await _saveTodos(updatedTodos);
    state = AsyncValue.data(updatedTodos);
  }

  Future<void> _updateCategoryTaskCount(String categoryId) async {
    final currentTodos = await future;
    final categoryTodos = currentTodos.where((t) => t.categoryId == categoryId).toList();
    final taskCount = categoryTodos.where((t) => !t.isCompleted).length;
    
    await ref.read(categoryNotifierProvider.notifier).updateTaskCount(categoryId, taskCount);
  }

  Future<void> _updateCategoryTaskCountAsync(String categoryId) async {
    // Async version that doesn't block UI updates
    try {
      final currentTodos = await future;
      final categoryTodos = currentTodos.where((t) => t.categoryId == categoryId).toList();
      final taskCount = categoryTodos.where((t) => !t.isCompleted).length;
      
      await ref.read(categoryNotifierProvider.notifier).updateTaskCount(categoryId, taskCount);
    } catch (e) {
      // Silently handle errors to avoid breaking UI
    }
  }
}
