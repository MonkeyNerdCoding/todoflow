import 'package:flutter/material.dart';
import '../../shared/constants/app_constants.dart';

enum Priority {
  low,
  medium,
  high;

  /// Display name for each priority level
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  /// Corresponding color for each priority level
  Color get color {
    switch (this) {
      case Priority.low:
        return AppConstants.priorityLowColor;
      case Priority.medium:
        return AppConstants.priorityMediumColor;
      case Priority.high:
        return AppConstants.priorityHighColor;
    }
  }

  /// Icon that visually represents the priority
  IconData get icon {
    switch (this) {
      case Priority.low:
        return Icons.keyboard_arrow_down;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.keyboard_arrow_up;
    }
  }

  /// Used to sort by priority level
  int get order {
    switch (this) {
      case Priority.low:
        return 1;
      case Priority.medium:
        return 2;
      case Priority.high:
        return 3;
    }
  }

  /// Parse string (e.g., from JSON or API) to [Priority]
  static Priority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        throw ArgumentError('Invalid priority: $value');
    }
  }

  /// Convert Priority to lowercase string for storage
  String get toJson => name;
}
