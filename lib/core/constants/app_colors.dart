import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryColor = Color(0xFF2E86AB); // Professional Blue
  static const Color primaryDark = Color(0xFF1B5E7F); // Darker Blue
  static const Color primaryLight = Color(0xFF5BA3C7); // Lighter Blue

  // Accent Colors
  static const Color accentColor = Color(0xFFF18F01); // Orange accent
  static const Color accentDark = Color(0xFFD67800); // Darker Orange
  static const Color accentLight = Color(0xFFF4A94B); // Lighter Orange

  // Background Colors
  static const Color backgroundColor = Color(0xFFF8F9FA); // Light Gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color cardColor = Color(0xFFFFFFFF); // White

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436); // Dark Gray
  static const Color textSecondary = Color(0xFF636E72); // Medium Gray
  static const Color textTertiary = Color(0xFF95A5A6); // Light Gray
  static const Color textWhite = Color(0xFFFFFFFF); // White

  // Status Colors
  static const Color successColor = Color(0xFF00B894); // Green
  static const Color errorColor = Color(0xFFE74C3C); // Red
  static const Color warningColor = Color(0xFFF39C12); // Yellow
  static const Color infoColor = Color(0xFF3498DB); // Blue

  // Border and Divider Colors
  static const Color borderColor = Color(0xFFE1E5E9); // Light Border
  static const Color dividerColor = Color(0xFFECF0F1); // Very Light Gray

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000); // 10% Black
  static const Color lightShadow = Color(0x0D000000); // 5% Black

  // Shopping Cart & E-commerce Specific Colors
  static const Color addToCartColor = Color(
    0xFF27AE60,
  ); // Green for Add to Cart
  static const Color discountColor = Color(0xFFE74C3C); // Red for Discounts
  static const Color ratingColor = Color(0xFFF39C12); // Yellow for Stars
  static const Color outOfStockColor = Color(
    0xFF95A5A6,
  ); // Gray for Out of Stock

  // Button Colors
  static const Color buttonPrimary = primaryColor;
  static const Color buttonSecondary = Color(0xFF74B9FF); // Light Blue
  static const Color buttonDisabled = Color(0xFFBDC3C7); // Gray

  // Input Field Colors
  static const Color inputFillColor = Color(0xFFF8F9FA); // Very Light Gray
  static const Color inputBorderColor = Color(0xFFE1E5E9); // Light Gray
  static const Color inputFocusedBorderColor = primaryColor;

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Additional Utility Colors
  static const Color transparent = Colors.transparent;
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Shopping Categories Colors (Optional for category icons)
  static const Color electronicsColor = Color(0xFF3498DB); // Blue
  static const Color fashionColor = Color(0xFFE91E63); // Pink
  static const Color homeColor = Color(0xFF4CAF50); // Green
  static const Color booksColor = Color(0xFF9C27B0); // Purple
  static const Color sportsColor = Color(0xFFFF9800); // Orange

  // Dark Background Colors
  static const Color darkBackgroundColor = Color(0xFF121212); // Very Dark Gray
  static const Color darkSurfaceColor = Color(0xFF1E1E1E); // Dark Gray
  static const Color darkCardColor = Color(0xFF252525); // Slightly Lighter Dark

  // Dark Text Colors
  static const Color darkTextPrimary = Color(0xFFE1E1E1); // Light Gray
  static const Color darkTextSecondary = Color(0xFFB3B3B3); // Medium Gray
  static const Color darkTextTertiary = Color(0xFF8A8A8A); // Darker Gray

  // Dark Border Colors
  static const Color darkBorderColor = Color(0xFF404040); // Dark Border
  static const Color darkDividerColor = Color(0xFF303030); // Dark Divider

  // Dark Input Colors
  static const Color darkInputFillColor = Color(0xFF2A2A2A); // Dark Input
  static const Color darkInputBorderColor = Color(
    0xFF404040,
  ); // Dark Input Border

  // Dark Shadow Colors
  static const Color darkShadowColor = Color(
    0x40000000,
  ); // Stronger shadow for dark theme
  static const Color darkLightShadow = Color(
    0x20000000,
  ); // Light shadow for dark theme

  // Dark Gradients
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF1B5E7F), Color(0xFF2E86AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Get color by name (utility method)
  static Color getColorByName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'primary':
        return primaryColor;
      case 'accent':
        return accentColor;
      case 'success':
        return successColor;
      case 'error':
        return errorColor;
      case 'warning':
        return warningColor;
      case 'info':
        return infoColor;
      default:
        return primaryColor;
    }
  }
}

// Theme Extensions for easier usage
// Theme Extensions for easier usage
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(0xFF2E86AB, {
        50: const Color(0xFFE3F2FD),
        100: const Color(0xFFBBDEFB),
        200: const Color(0xFF90CAF9),
        300: const Color(0xFF64B5F6),
        400: const Color(0xFF42A5F5),
        500: AppColors.primaryColor,
        600: const Color(0xFF1E88E5),
        700: const Color(0xFF1976D2),
        800: const Color(0xFF1565C0),
        900: const Color(0xFF0D47A1),
      }),
      primaryColor: AppColors.primaryColor,
      // Remove deprecated accentColor
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      cardColor: AppColors.cardColor,
      // errorColor: AppColors.errorColor, // Removed: not supported in ThemeData
      dividerColor: AppColors.dividerColor,
      textTheme: const TextTheme(
        // Update deprecated text styles
        displayLarge: TextStyle(color: AppColors.textPrimary), // headline1
        displayMedium: TextStyle(color: AppColors.textPrimary), // headline2
        bodyLarge: TextStyle(color: AppColors.textPrimary), // bodyText1
        bodyMedium: TextStyle(color: AppColors.textSecondary), // bodyText2
        bodySmall: TextStyle(color: AppColors.textTertiary), // caption
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceColor,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // Update deprecated properties
          backgroundColor: AppColors.buttonPrimary, // primary
          foregroundColor: AppColors.textWhite, // onPrimary
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.inputFillColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  // ADD THIS DARK THEME METHOD
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: MaterialColor(0xFF2E86AB, {
        50: const Color(0xFF1a1a1a),
        100: const Color(0xFF2d2d2d),
        200: const Color(0xFF404040),
        300: const Color(0xFF525252),
        400: const Color(0xFF656565),
        500: AppColors.primaryColor,
        600: const Color(0xFF3498db),
        700: const Color(0xFF2980b9),
        800: const Color(0xFF1f618d),
        900: const Color(0xFF154360),
      }),
      primaryColor: AppColors.primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
        surface: AppColors.darkSurfaceColor,
        background: AppColors.darkBackgroundColor,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.darkTextPrimary,
        onBackground: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      cardColor: AppColors.darkCardColor,
      dividerColor: AppColors.darkDividerColor,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.darkTextPrimary),
        displayMedium: TextStyle(color: AppColors.darkTextPrimary),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
        bodySmall: TextStyle(color: AppColors.darkTextTertiary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurfaceColor,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.textWhite,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.darkInputFillColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkInputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }
}
