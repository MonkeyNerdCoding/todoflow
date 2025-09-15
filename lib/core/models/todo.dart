import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'priority.dart';
import 'subtask.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    String? description,
    required String categoryId,
    @Default(Priority.medium) Priority priority,
    DateTime? dueDate,
    DateTime? dueTime,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    DateTime? completedAt,
    @Default([]) List<Subtask> subtasks,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  // Factory constructor to create a new todo with generated ID
  factory Todo.create({
    required String title,
    String? description,
    required String categoryId,
    Priority priority = Priority.medium,
    DateTime? dueDate,
    DateTime? dueTime,
  }) {
    return Todo(
      id: const Uuid().v4(),
      title: title,
      description: description,
      categoryId: categoryId,
      priority: priority,
      dueDate: dueDate,
      dueTime: dueTime,
      isCompleted: false,
      createdAt: DateTime.now(),
      subtasks: [],
    );
  }
}

// Extension for Todo utilities and computed properties
extension TodoExtension on Todo {
  // Toggle completion status
  Todo toggleCompletion() {
    return copyWith(
      isCompleted: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
    );
  }

  // Mark as completed
  Todo markCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  // Mark as pending
  Todo markPending() {
    return copyWith(
      isCompleted: false,
      completedAt: null,
    );
  }

  // Update todo details
  Todo updateDetails({
    String? title,
    String? description,
    String? categoryId,
    Priority? priority,
    DateTime? dueDate,
    DateTime? dueTime,
  }) {
    return copyWith(
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
    );
  }

  // Add subtask
  Todo addSubtask(Subtask subtask) {
    final updatedSubtasks = List<Subtask>.from(subtasks)..add(subtask);
    return copyWith(subtasks: updatedSubtasks);
  }

  // Remove subtask
  Todo removeSubtask(String subtaskId) {
    final updatedSubtasks = subtasks.where((s) => s.id != subtaskId).toList();
    return copyWith(subtasks: updatedSubtasks);
  }

  // Update subtask
  Todo updateSubtask(Subtask updatedSubtask) {
    final updatedSubtasks = subtasks.map((s) {
      return s.id == updatedSubtask.id ? updatedSubtask : s;
    }).toList();
    return copyWith(subtasks: updatedSubtasks);
  }

  // Computed properties
  int get completedSubtasksCount {
    return subtasks.where((s) => s.isCompleted).length;
  }

  int get totalSubtasksCount {
    return subtasks.length;
  }

  double get subtaskProgress {
    if (subtasks.isEmpty) return 0.0;
    return completedSubtasksCount / totalSubtasksCount;
  }

  bool get hasSubtasks {
    return subtasks.isNotEmpty;
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final due = dueTime != null 
        ? DateTime(dueDate!.year, dueDate!.month, dueDate!.day, 
                   dueTime!.hour, dueTime!.minute)
        : dueDate!;
    return now.isAfter(due);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
           dueDate!.month == now.month &&
           dueDate!.day == now.day;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
           dueDate!.month == tomorrow.month &&
           dueDate!.day == tomorrow.day;
  }

  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return dueDate!.isAfter(now) && dueDate!.isBefore(weekFromNow);
  }

  String get dueDateDisplay {
    if (dueDate == null) return '';
    
    if (isOverdue) return 'Overdue';
    if (isDueToday) return 'Today';
    if (isDueTomorrow) return 'Tomorrow';
    if (isDueThisWeek) return 'This Week';
    
    // Format date for display
    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }
}
