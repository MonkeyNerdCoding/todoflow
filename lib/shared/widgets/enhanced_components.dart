// import 'package:flutter/material.dart';
 

// /// Enhanced Material widget with improved ripple effects and touch feedback
// class EnhancedMaterial extends StatelessWidget {
//   final Widget child;
//   final VoidCallback? onTap;
//   final VoidCallback? onLongPress;
//   final BorderRadius? borderRadius;
//   final Color? color;
//   final Color? highlightColor;
//   final Color? splashColor;
//   final double? elevation;
//   final EdgeInsets? padding;
//   final bool enableFeedback;
  
//   const EnhancedMaterial({
//     super.key,
//     required this.child,
//     this.onTap,
//     this.onLongPress,
//     this.borderRadius,
//     this.color,
//     this.highlightColor,
//     this.splashColor,
//     this.elevation,
//     this.padding,
//     this.enableFeedback = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     return Material(
//       color: color ?? Colors.transparent,
//       elevation: elevation ?? 0,
//       borderRadius: borderRadius,
//       child: InkWell(
//         onTap: onTap,
//         onLongPress: onLongPress,
//         borderRadius: borderRadius,
//         enableFeedback: enableFeedback,
//         highlightColor: highlightColor ?? colorScheme.primary.withValues(alpha: 0.08),
//         splashColor: splashColor ?? colorScheme.primary.withValues(alpha: 0.12),
//         splashFactory: InkRipple.splashFactory,
//         child: padding != null 
//             ? Padding(padding: padding!, child: child)
//             : child,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

/// A reusable widget that wraps a child with Material and InkWell
/// to provide ripple effects, elevation, and tap/long-press feedback.
class TouchSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color? splashColor;
  final Color? highlightColor;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final bool hapticFeedback;

  const TouchSurface({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius = BorderRadius.zero,
    this.backgroundColor = Colors.transparent,
    this.splashColor,
    this.highlightColor,
    this.elevation = 0,
    this.padding,
    this.hapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: backgroundColor,
      borderRadius: borderRadius,
      elevation: elevation,
      child: InkWell(
        onTap: () {
          if (hapticFeedback) Feedback.forTap(context);
          onTap?.call();
        },
        onLongPress: () {
          if (hapticFeedback) Feedback.forLongPress(context);
          onLongPress?.call();
        },
        borderRadius: borderRadius,
        splashFactory: InkRipple.splashFactory,
        splashColor: splashColor ?? scheme.primary.withOpacity(0.12),
        highlightColor: highlightColor ?? scheme.primary.withOpacity(0.08),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}
