import 'package:flutter/material.dart';
import '../../shared/constants/app_constants.dart';

enum Priority {
  low,
  medium,
  high;

  // Display names
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

  // Priority colors
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

  // Priority icons
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

  // Priority order for sorting
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
}


