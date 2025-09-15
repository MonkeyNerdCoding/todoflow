import 'package:flutter/material.dart';
 

/// Enhanced Material widget with improved ripple effects and touch feedback
class EnhancedMaterial extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? highlightColor;
  final Color? splashColor;
  final double? elevation;
  final EdgeInsets? padding;
  final bool enableFeedback;
  
  const EnhancedMaterial({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.color,
    this.highlightColor,
    this.splashColor,
    this.elevation,
    this.padding,
    this.enableFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Material(
      color: color ?? Colors.transparent,
      elevation: elevation ?? 0,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        enableFeedback: enableFeedback,
        highlightColor: highlightColor ?? colorScheme.primary.withValues(alpha: 0.08),
        splashColor: splashColor ?? colorScheme.primary.withValues(alpha: 0.12),
        splashFactory: InkRipple.splashFactory,
        child: padding != null 
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
