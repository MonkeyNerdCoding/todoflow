// import 'package:flutter/material.dart';
// import '../../shared/constants/app_constants.dart';

// enum Priority {
//   low,
//   medium,
//   high;

//   // Display names
//   String get displayName {
//     switch (this) {
//       case Priority.low:
//         return 'Low';
//       case Priority.medium:
//         return 'Medium';
//       case Priority.high:
//         return 'High';
//     }
//   }

//   // Priority colors
//   Color get color {
//     switch (this) {
//       case Priority.low:
//   return AppConstants.priorityLowColor;
//       case Priority.medium:
//   return AppConstants.priorityMediumColor;
//       case Priority.high:
//   return AppConstants.priorityHighColor;
//     }
//   }

//   // Priority icons
//   IconData get icon {
//     switch (this) {
//       case Priority.low:
//         return Icons.keyboard_arrow_down;
//       case Priority.medium:
//         return Icons.remove;
//       case Priority.high:
//         return Icons.keyboard_arrow_up;
//     }
//   }

//   // Priority order for sorting
//   int get order {
//     switch (this) {
//       case Priority.low:
//         return 1;
//       case Priority.medium:
//         return 2;
//       case Priority.high:
//         return 3;
//     }
//   }
// }

import 'package:flutter/material.dart';
import '../../shared/constants/app_constants.dart';

enum Priority { low, medium, high }

extension PriorityX on Priority {
  // Display names
  String get displayName => {
        Priority.low: 'Low',
        Priority.medium: 'Medium',
        Priority.high: 'High',
      }[this]!;

  // Priority colors
  Color get color => {
        Priority.low: AppConstants.priorityLowColor,
        Priority.medium: AppConstants.priorityMediumColor,
        Priority.high: AppConstants.priorityHighColor,
      }[this]!;

  // Priority icons
  IconData get icon => {
        Priority.low: Icons.keyboard_arrow_down,
        Priority.medium: Icons.remove,
        Priority.high: Icons.keyboard_arrow_up,
      }[this]!;

  // Priority order
  int get order => {
        Priority.low: 1,
        Priority.medium: 2,
        Priority.high: 3,
      }[this]!;
}
