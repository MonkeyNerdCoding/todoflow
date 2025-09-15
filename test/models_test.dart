import 'package:flutter_test/flutter_test.dart';
import 'package:todoflow/core/models/models.dart';

void main() {
  group('TodoFlow Models Tests', () {
    test('Category model creation and serialization', () {
      final category = Category.create(
        name: 'Work',
        description: 'Work related tasks',
        colorCode: CategoryColors.blue,
        iconName: CategoryIcons.work,
      );

      expect(category.name, 'Work');
      expect(category.description, 'Work related tasks');
      expect(category.colorCode, CategoryColors.blue);
      expect(category.iconName, CategoryIcons.work);
      expect(category.isActive, true);
      expect(category.taskCount, 0);

      // Test JSON serialization
      final json = category.toJson();
      final fromJson = Category.fromJson(json);
      expect(fromJson.name, category.name);
      expect(fromJson.id, category.id);
    });

    test('Todo model creation and utilities', () {
      final todo = Todo.create(
        title: 'Test Todo',
        description: 'This is a test todo',
        categoryId: 'category-1',
        priority: Priority.high,
      );

      expect(todo.title, 'Test Todo');
      expect(todo.priority, Priority.high);
      expect(todo.isCompleted, false);
      expect(todo.isDueToday, false);
      expect(todo.isOverdue, false);

      // Test completion toggle
      final completedTodo = todo.toggleCompletion();
      expect(completedTodo.isCompleted, true);
      expect(completedTodo.completedAt, isNotNull);

      // Test JSON serialization
      final json = todo.toJson();
      final fromJson = Todo.fromJson(json);
      expect(fromJson.title, todo.title);
      expect(fromJson.id, todo.id);
    });

    test('Subtask model creation and utilities', () {
      final subtask = Subtask.create(
        title: 'Test Subtask',
        parentTodoId: 'todo-1',
      );

      expect(subtask.title, 'Test Subtask');
      expect(subtask.parentTodoId, 'todo-1');
      expect(subtask.isCompleted, false);

      // Test completion toggle
      final completedSubtask = subtask.toggleCompletion();
      expect(completedSubtask.isCompleted, true);
      expect(completedSubtask.completedAt, isNotNull);

      // Test JSON serialization
      final json = subtask.toJson();
      final fromJson = Subtask.fromJson(json);
      expect(fromJson.title, subtask.title);
      expect(fromJson.id, subtask.id);
    });

    test('Priority enum utilities', () {
      expect(Priority.low.displayName, 'Low');
      expect(Priority.medium.displayName, 'Medium');
      expect(Priority.high.displayName, 'High');

      expect(Priority.low.order, 1);
      expect(Priority.medium.order, 2);
      expect(Priority.high.order, 3);
    });

    test('Todo with subtasks functionality', () {
      final todo = Todo.create(
        title: 'Todo with Subtasks',
        categoryId: 'category-1',
      );

      final subtask1 = Subtask.create(
        title: 'Subtask 1',
        parentTodoId: todo.id,
      );

      final subtask2 = Subtask.create(
        title: 'Subtask 2',
        parentTodoId: todo.id,
      );

      // Add subtasks
      final todoWithSubtasks = todo
          .addSubtask(subtask1)
          .addSubtask(subtask2);

      expect(todoWithSubtasks.totalSubtasksCount, 2);
      expect(todoWithSubtasks.completedSubtasksCount, 0);
      expect(todoWithSubtasks.subtaskProgress, 0.0);
      expect(todoWithSubtasks.hasSubtasks, true);

      // Complete one subtask
      final completedSubtask1 = subtask1.toggleCompletion();
      final updatedTodo = todoWithSubtasks.updateSubtask(completedSubtask1);

      expect(updatedTodo.completedSubtasksCount, 1);
      expect(updatedTodo.subtaskProgress, 0.5);
    });
  });
}
