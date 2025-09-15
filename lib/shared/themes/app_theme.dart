import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// TodoFlow Theme Configuration
/// Centralized theme management following Material Design 3 guidelines
class AppTheme {
  AppTheme._();

  // Light Theme Configuration
  static ThemeData get lightTheme {
    const ColorScheme colorScheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: Color(0xFF2196F3), // Bright blue (matches Today's Tasks)
      onPrimary: Color(0xFFFFFFFF), // White
      primaryContainer: Color(0xFFBBDEFB), // Light blue container
      onPrimaryContainer: Color(0xFF0D47A1), // Dark blue text
      
      secondary: Color(0xFF4CAF50), // Green (matches Completed)
      onSecondary: Color(0xFFFFFFFF), // White
      secondaryContainer: Color(0xFFC8E6C9), // Light green container
      onSecondaryContainer: Color(0xFF1B5E20), // Dark green text
      
      tertiary: Color(0xFFFF9800), // Orange (matches Pending)
      onTertiary: Color(0xFFFFFFFF), // White
      tertiaryContainer: Color(0xFFFFE0B2), // Light orange container
      onTertiaryContainer: Color(0xFFE65100), // Dark orange text
      
      error: Color(0xFFF44336), // Red
      onError: Color(0xFFFFFFFF), // White
      errorContainer: Color(0xFFFFCDD2), // Light red container
      onErrorContainer: Color(0xFFC62828), // Dark red text
      
      surface: Color(0xFFFFFFFF), // White
      onSurface: Color(0xFF1C1B1F), // Dark grey
      surfaceContainer: Color(0xFFF5F5F5), // Light grey
      surfaceContainerHigh: Color(0xFFEEEEEE), // Medium light grey
      surfaceContainerHighest: Color(0xFFE0E0E0), // Medium grey
      onSurfaceVariant: Color(0xFF49454F), // Medium grey
      
      outline: Color(0xFF79747E), // Border grey
      outlineVariant: Color(0xFFCAC4D0), // Light border grey
      shadow: Color(0xFF000000), // Black shadow
      scrim: Color(0xFF000000), // Black overlay
      inverseSurface: Color(0xFF313033), // Dark grey
      onInverseSurface: Color(0xFFF4EFF4), // Light grey
      inversePrimary: Color(0xFF90CAF9), // Light blue
      surfaceTint: Color(0xFF2196F3), // Blue tint
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Typography
      textTheme: _buildTextTheme(colorScheme),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: AppConstants.elevationS,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: AppConstants.elevationM,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        margin: const EdgeInsets.all(AppConstants.spacingS),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: AppConstants.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: AppConstants.elevationXl,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingM,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: AppConstants.elevationM,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXxl,
            vertical: AppConstants.spacingL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
      
      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXxl,
            vertical: AppConstants.spacingL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: colorScheme.primary,
        disabledColor: colorScheme.surfaceContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),
      
      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  // Dark Theme Configuration
  static ThemeData get darkTheme {
    const ColorScheme colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: Color(0xFF90CAF9), // Light blue for dark theme
      onPrimary: Color(0xFF003258), // Dark blue text
      primaryContainer: Color(0xFF004881), // Medium blue container
      onPrimaryContainer: Color(0xFFD1E4FF), // Light blue text
      
      secondary: Color(0xFF81C784), // Light green for dark theme
      onSecondary: Color(0xFF003910), // Dark green text
      secondaryContainer: Color(0xFF005227), // Medium green container
      onSecondaryContainer: Color(0xFF9DF9A4), // Light green text
      
      tertiary: Color(0xFFFFCC02), // Amber for dark theme
      onTertiary: Color(0xFF3E2723), // Dark brown text
      tertiaryContainer: Color(0xFF795548), // Brown container
      onTertiaryContainer: Color(0xFFFFF8E1), // Light amber text
      
      error: Color(0xFFFFB4AB), // Light red for dark theme
      onError: Color(0xFF690005), // Dark red text
      errorContainer: Color(0xFF93000A), // Medium red container
      onErrorContainer: Color(0xFFFFDAD6), // Light red text
      
      surface: Color(0xFF121212), // Dark background
      onSurface: Color(0xFFE6E1E5), // Light text
      surfaceContainer: Color(0xFF1E1E1E), // Elevated container
      surfaceContainerHigh: Color(0xFF2C2C2C), // Higher elevation
      surfaceContainerHighest: Color(0xFF3A3A3A), // Highest elevation
      onSurfaceVariant: Color(0xFFC6C2CA), // Medium contrast text
      
      outline: Color(0xFF938F96), // Medium grey borders
      outlineVariant: Color(0xFF49454F), // Subtle borders
      shadow: Color(0xFF000000), // Black shadow
      scrim: Color(0xFF000000), // Black overlay
      inverseSurface: Color(0xFFE6E1E5), // Light surface for dark theme
      onInverseSurface: Color(0xFF313033), // Dark text on light surface
      inversePrimary: Color(0xFF1976D2), // Original blue
      surfaceTint: Color(0xFF90CAF9), // Primary tint
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Typography
      textTheme: _buildTextTheme(colorScheme),
      
      // App Bar Theme - Enhanced for dark mode
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurface,
        elevation: AppConstants.elevationS,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      
      // Card Theme - Enhanced for dark mode
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: AppConstants.elevationM,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        margin: const EdgeInsets.all(AppConstants.spacingS),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: AppConstants.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
      ),
      
      // Bottom Navigation Bar Theme - Enhanced for dark mode
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: AppConstants.elevationXl,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
      
      // Input Decoration Theme - Enhanced for dark mode
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingM,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: AppConstants.elevationM,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXxl,
            vertical: AppConstants.spacingL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXxl,
            vertical: AppConstants.spacingL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: colorScheme.primary,
        disabledColor: colorScheme.surfaceContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),
      
      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  // Private helper method to build consistent text theme
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      
      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      
      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      
      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: colorScheme.onSurface,
      ),
    );
  }
}

/// TextTheme Extension for TodoFlow
extension TodoFlowTextTheme on TextTheme {
  /// Category card text style
  TextStyle get categoryName => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}
