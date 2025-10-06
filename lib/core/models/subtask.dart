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

  factory Subtask.fromJson(Map<String, dynamic> json) =>
      _$SubtaskFromJson(json);

  /// Create a new Subtask with auto-generated ID and timestamp
  factory Subtask.create({
    required String title,
    required String parentTodoId,
  }) {
    return Subtask(
      id: const Uuid().v4(),
      title: title.trim(),
      parentTodoId: parentTodoId,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }
}

extension SubtaskExtension on Subtask {
  /// Toggle completion status
  Subtask toggleCompletion() => copyWith(
        isCompleted: !isCompleted,
        completedAt: !isCompleted ? DateTime.now() : null,
      );

  /// Update subtask title (automatically trims whitespace)
  Subtask updateTitle(String newTitle) =>
      copyWith(title: newTitle.trim());

  /// Mark subtask as completed
  Subtask markCompleted() => copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

  /// Mark subtask as pending (not completed)
  Subtask markPending() => copyWith(
        isCompleted: false,
        completedAt: null,
      );

  /// Check if the subtask is recently completed (within the last 24 hours)
  bool get isRecentlyCompleted =>
      isCompleted &&
      completedAt != null &&
      DateTime.now().difference(completedAt!).inHours < 24;
}
