import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'subtask.freezed.dart';
part 'subtask.g.dart';

@freezed
class Subtask with _$Subtask {
  const factory Subtask({
    required String id,
    required String title,
    required String parentTodoId,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Subtask;

  factory Subtask.fromJson(Map<String, dynamic> json) => _$SubtaskFromJson(json);

  // Factory constructor to create a new subtask with generated ID
  factory Subtask.create({
    required String title,
    required String parentTodoId,
  }) {
    return Subtask(
      id: const Uuid().v4(),
      title: title,
      parentTodoId: parentTodoId,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }
}

// Extension for Subtask utilities
extension SubtaskExtension on Subtask {
  // Toggle completion status
  Subtask toggleCompletion() {
    return copyWith(
      isCompleted: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
    );
  }

  // Update subtask title
  Subtask updateTitle(String newTitle) {
    return copyWith(title: newTitle);
  }

  // Mark as completed
  Subtask markCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  // Mark as pending
  Subtask markPending() {
    return copyWith(
      isCompleted: false,
      completedAt: null,
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'subtask.freezed.dart';
part 'subtask.g.dart';

@freezed
class Subtask with _$Subtask {
  const factory Subtask({
    required String id,
    required String title,
    required String parentTodoId,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Subtask;

  factory Subtask.fromJson(Map<String, dynamic> json) => _$SubtaskFromJson(json);

  // Factory constructor to create a new subtask with generated ID
  factory Subtask.create({
    required String title,
    required String parentTodoId,
  }) {
    return Subtask(
      id: const Uuid().v4(),
      title: title,
      parentTodoId: parentTodoId,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }
}

// Extension for Subtask utilities
extension SubtaskExtension on Subtask {
  // Toggle completion status
  Subtask toggleCompletion() {
    return copyWith(
      isCompleted: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
    );
  }

  // Update subtask title
  Subtask updateTitle(String newTitle) {
    return copyWith(title: newTitle);
  }

  // Mark as completed
  Subtask markCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  // Mark as pending
  Subtask markPending() {
    return copyWith(
      isCompleted: false,
      completedAt: null,
    );
  }
}
