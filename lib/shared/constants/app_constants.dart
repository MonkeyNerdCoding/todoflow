import 'package:flutter/material.dart';

/// Design constants for TodoFlow application
/// Following Material Design 3 guidelines for consistency
class AppConstants {
  AppConstants._();

  // SPACING
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;
  static const double spacingXxxl = 32.0;

  // BORDER RADIUS
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 20.0;

  // ELEVATION
  static const double elevationNone = 0.0;
  static const double elevationS = 1.0;
  static const double elevationM = 2.0;
  static const double elevationL = 4.0;
  static const double elevationXl = 8.0;

  // ICON SIZES
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXl = 28.0;
  static const double iconXxl = 32.0;
  static const double iconXxxl = 48.0;

  // COMPONENT SIZES
  static const double checkboxSize = 24.0;
  static const double categoryCardWidth = 90.0;
  static const double categoryCardHeight = 100.0;
  static const double priorityIndicatorWidth = 4.0;
  static const double priorityIndicatorHeight = 40.0;

  // ANIMATION DURATIONS
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // BREAKPOINTS (for responsive design)
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  // SEMANTIC COLORS (priority colors)
  static const Color priorityLowColor = Color(0xFF4CAF50); // Green
  static const Color priorityMediumColor = Color(0xFFFF9800); // Orange
  static const Color priorityHighColor = Color(0xFFF44336); // Red

  // STATUS COLORS
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color infoColor = Color(0xFF2196F3); // Blue

  // STAT CARD COLORS (Consistent across app)
  static const Color todayTasksColor = Color(0xFF2196F3); // Bright blue
  static const Color completedColor = Color(0xFF4CAF50); // Green
  static const Color pendingColor = Color(0xFFFF9800); // Orange
  static const Color overdueColor = Color(0xFFF44336); // Red for overdue items
  static const Color categoriesColor = Color(0xFF9C27B0); // Purple

  // OPACITY VALUES
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.60;
  static const double opacityHigh = 0.87;
  static const double opacityOverlay = 0.20;

  // TEXT CONSTRAINTS
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 300;
  static const int maxCategoryNameLength = 30;
  static const int maxCategoryDescriptionLength = 100;
  static const int maxSubtaskTitleLength = 50;

  // LIST LIMITS
  static const int recentTodosLimit = 10;
  static const int maxSubtasksPerTodo = 20;

  // VISUAL FEEDBACK
  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration tooltipShowDuration = Duration(seconds: 1);
}

/// Typography extensions for consistent text styling
extension AppTextStyles on TextTheme {
  // Consistent heading styles
  TextStyle get dashboardHeading => titleMedium!.copyWith(
    fontWeight: FontWeight.w600,
  );

  TextStyle get sectionHeading => titleSmall!.copyWith(
    fontWeight: FontWeight.w600,
  );

  TextStyle get statCardNumber => headlineMedium!.copyWith(
    fontWeight: FontWeight.bold,
  );

  TextStyle get statCardLabel => bodyMedium!.copyWith(
    fontWeight: FontWeight.w500,
  );

  TextStyle get todoTitle => bodyLarge!.copyWith(
    fontWeight: FontWeight.w500,
  );

  TextStyle get todoSubtitle => bodyMedium!.copyWith(
    fontWeight: FontWeight.normal,
  );

  TextStyle get categoryName => bodySmall!.copyWith(
    fontWeight: FontWeight.w600,
  );

  TextStyle get chipLabel => bodySmall!.copyWith(
    fontWeight: FontWeight.w500,
  );

  TextStyle get errorText => bodyMedium!;
}

/// Color scheme extensions for consistent color usage
extension AppColorScheme on ColorScheme {
  // Priority colors that adapt to theme
  Color get priorityLow => brightness == Brightness.light
      ? AppConstants.priorityLowColor
      : AppConstants.priorityLowColor.withValues(alpha: 0.8);

  Color get priorityMedium => brightness == Brightness.light
      ? AppConstants.priorityMediumColor
      : AppConstants.priorityMediumColor.withValues(alpha: 0.8);

  Color get priorityHigh => brightness == Brightness.light
      ? AppConstants.priorityHighColor
      : AppConstants.priorityHighColor.withValues(alpha: 0.8);

  // Status colors that adapt to theme
  Color get success => brightness == Brightness.light
      ? AppConstants.successColor
      : AppConstants.successColor.withValues(alpha: 0.8);

  Color get warning => brightness == Brightness.light
      ? AppConstants.warningColor
      : AppConstants.warningColor.withValues(alpha: 0.8);

  Color get info => brightness == Brightness.light
      ? AppConstants.infoColor
      : AppConstants.infoColor.withValues(alpha: 0.8);

  // Stat card colors that adapt to theme
  Color get todayTasks => brightness == Brightness.light
      ? AppConstants.todayTasksColor
      : AppConstants.todayTasksColor.withValues(alpha: 0.8);

  Color get completed => brightness == Brightness.light
      ? AppConstants.completedColor
      : AppConstants.completedColor.withValues(alpha: 0.8);

  Color get pending => brightness == Brightness.light
      ? AppConstants.pendingColor
      : AppConstants.pendingColor.withValues(alpha: 0.8);

  Color get overdue => brightness == Brightness.light
      ? AppConstants.overdueColor
      : AppConstants.overdueColor.withValues(alpha: 0.8);

  Color get categories => brightness == Brightness.light
      ? AppConstants.categoriesColor
      : AppConstants.categoriesColor.withValues(alpha: 0.8);
}

/// Common widget decorations for consistency
class AppDecorations {
  AppDecorations._();

  // Card decorations
  static BoxDecoration cardDecoration(ColorScheme colorScheme) => BoxDecoration(
    color: colorScheme.surfaceContainer,
    borderRadius: BorderRadius.circular(AppConstants.radiusM),
    boxShadow: [
      BoxShadow(
        color: colorScheme.shadow.withValues(alpha: 0.1),
        blurRadius: AppConstants.elevationL,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Stat card decoration
  static BoxDecoration statCardDecoration(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(AppConstants.radiusL),
  );

  // Tonal stat card decoration (distinct from category cards)
  // Uses a neutral surface container with an accent border to avoid
  // looking like the solid-colored category tiles.
  static BoxDecoration statCardTonalDecoration(
    ColorScheme colorScheme,
    Color accent,
  ) => BoxDecoration(
    color: colorScheme.surfaceContainerHigh,
    borderRadius: BorderRadius.circular(AppConstants.radiusL),
    border: Border.all(
      color: accent.withValues(alpha: 0.30),
      width: 1.5,
    ),
  );

  // Category card decoration
  static BoxDecoration categoryCardDecoration(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(AppConstants.radiusL),
  );

  // Priority indicator decoration
  static BoxDecoration priorityIndicatorDecoration(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(AppConstants.radiusS / 4),
  );

  // Checkbox decoration
  static BoxDecoration checkboxDecoration(Color color, bool isCompleted) => BoxDecoration(
    color: isCompleted ? color : Colors.transparent,
    border: Border.all(
      color: color,
      width: 2,
    ),
  borderRadius: BorderRadius.circular(AppConstants.radiusS),
  );

  // Selectable card decoration (for todo items, categories, etc.)
  static BoxDecoration selectableCardDecoration(
    ColorScheme colorScheme, {
    bool isSelected = false,
  }) => BoxDecoration(
    color: colorScheme.surfaceContainer,
    borderRadius: BorderRadius.circular(AppConstants.radiusM),
    border: Border.all(
      color: isSelected 
          ? colorScheme.primary 
          : colorScheme.outline.withValues(alpha: 0.2),
      width: isSelected ? 2 : 1,
    ),
    boxShadow: [
      BoxShadow(
        color: colorScheme.shadow.withValues(alpha: 0.1),
        blurRadius: AppConstants.elevationS,
        offset: const Offset(0, 1),
      ),
    ],
  );

  // Bottom navigation decoration
  static BoxDecoration bottomNavigationDecoration(ColorScheme colorScheme) => BoxDecoration(
    color: colorScheme.surfaceContainer,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(AppConstants.radiusXl),
      topRight: Radius.circular(AppConstants.radiusXl),
    ),
    boxShadow: [
      BoxShadow(
        color: colorScheme.shadow.withValues(alpha: 0.2),
        spreadRadius: 1,
        blurRadius: 10,
        offset: const Offset(0, -2),
      ),
    ],
  );

  // Category indicator decoration (small circular colored dot)
  static BoxDecoration categoryIndicatorDecoration(Color color) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
  );

  // Form field loading skeleton decoration
  static BoxDecoration formFieldSkeletonDecoration(ColorScheme colorScheme) => BoxDecoration(
    border: Border.all(color: colorScheme.outline),
    borderRadius: BorderRadius.circular(AppConstants.radiusM),
  );

  // Form field error state decoration
  static BoxDecoration formFieldErrorDecoration(ColorScheme colorScheme) => BoxDecoration(
    border: Border.all(color: colorScheme.error),
    borderRadius: BorderRadius.circular(AppConstants.radiusM),
  );

  // Loading content decoration (shimmer effect container)
  static BoxDecoration loadingContentDecoration(ColorScheme colorScheme) => BoxDecoration(
    color: colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(AppConstants.radiusS),
  );

  // Empty state content decoration
  static BoxDecoration emptyStateDecoration(ColorScheme colorScheme) => BoxDecoration(
    border: Border.all(color: colorScheme.outline),
    borderRadius: BorderRadius.circular(AppConstants.radiusS),
  );

  // Bottom action bar decoration
  static BoxDecoration bottomActionBarDecoration(ColorScheme colorScheme) => BoxDecoration(
    color: colorScheme.surface,
    boxShadow: [
      BoxShadow(
  color: colorScheme.shadow.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, -2),
      ),
    ],
  );
}

/// Consistent component sizing
class AppSizing {
  AppSizing._();

  // Responsive breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint &&
      MediaQuery.of(context).size.width < AppConstants.tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;

  // Responsive padding
  static EdgeInsets screenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(AppConstants.spacingL);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(AppConstants.spacingXxl);
    } else {
      return const EdgeInsets.all(AppConstants.spacingXxxl);
    }
  }

  // Common component sizes
  static const Size statCardMinSize = Size(150, 120);
  static const Size categoryCardSize = Size(
    AppConstants.categoryCardWidth,
    AppConstants.categoryCardHeight,
  );
  static const Size fabSize = Size(56, 56);
  static const Size checkboxSize = Size(
    AppConstants.checkboxSize,
    AppConstants.checkboxSize,
  );
}
