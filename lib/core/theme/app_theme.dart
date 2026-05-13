import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme({double fontSizeMultiplier = 1.0}) {
    final scaledTextTheme = _scaleTextTheme(_lightTextTheme, fontSizeMultiplier);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      // 1. Color Scheme
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryVariant,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryVariant,
        onSecondaryContainer: AppColors.onSecondary,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onSurface,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.grey400,
      ),

      // 2. Text Theme
      textTheme: scaledTextTheme,

      // 3. App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: scaledTextTheme.titleLarge?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
      ),

      // 4. Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: scaledTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side:   BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: scaledTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: scaledTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        elevation: 4,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.onSurfaceVariant,
        ),
      ),

      // 5. Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: scaledTextTheme.bodyMedium?.copyWith(
          color: AppColors.grey600,
        ),
        hintStyle: scaledTextTheme.bodyMedium?.copyWith(
          color: AppColors.grey400,
        ),
        prefixIconColor: AppColors.grey600,
        suffixIconColor: AppColors.grey600,
      ),

      // 6. Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // 7. Dialog & Bottom Sheet Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: scaledTextTheme.headlineSmall?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // 8. Navigation Themes
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        selectedIconTheme: IconThemeData(color: AppColors.primary),
        unselectedIconTheme: IconThemeData(color: AppColors.grey500),
        selectedLabelTextStyle: TextStyle(color: AppColors.primary),
        unselectedLabelTextStyle: TextStyle(color: AppColors.grey500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceVariant,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          scaledTextTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 9. Other Widgets
      dividerTheme: const DividerThemeData(
        color: AppColors.grey300,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey500;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey500;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey500;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.grey300;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primary.withValues(alpha: 0.3),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.1),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey900,
        contentTextStyle: scaledTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey200,
        disabledColor: AppColors.grey100,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        secondarySelectedColor: AppColors.secondary.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: scaledTextTheme.labelLarge?.copyWith(color: AppColors.onSurface),
        secondaryLabelStyle: scaledTextTheme.labelLarge?.copyWith(color: AppColors.primary),
        brightness: Brightness.light,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.grey600,
        textColor: AppColors.onSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey600,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: scaledTextTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: scaledTextTheme.titleSmall,
      ),
    );
  }

  static ThemeData darkTheme({double fontSizeMultiplier = 1.0}) {
    final scaledTextTheme = _scaleTextTheme(_darkTextTheme, fontSizeMultiplier);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,

      // 1. Color Scheme
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryVariant,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryVariant,
        onSecondaryContainer: AppColors.onSecondary,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onSurface,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        surfaceContainerHighest: AppColors.grey800,
        onSurfaceVariant: AppColors.grey300,
        outline: AppColors.grey600,
      ),

      // 2. Text Theme
      textTheme: scaledTextTheme,

      // 3. App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: scaledTextTheme.titleLarge?.copyWith(
          color: AppColors.darkOnSurface,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkOnSurface),
      ),

      // 4. Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: scaledTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: scaledTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: scaledTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        elevation: 4,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.grey300),
      ),

      // 5. Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey900,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: scaledTextTheme.bodyMedium?.copyWith(
          color: AppColors.grey400,
        ),
        hintStyle: scaledTextTheme.bodyMedium?.copyWith(
          color: AppColors.grey600,
        ),
        prefixIconColor: AppColors.grey400,
        suffixIconColor: AppColors.grey400,
      ),

      // 6. Card Theme
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // 7. Dialog & Bottom Sheet Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: scaledTextTheme.headlineSmall?.copyWith(
          color: AppColors.darkOnSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // 8. Navigation Themes
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedIconTheme: IconThemeData(color: AppColors.secondary),
        unselectedIconTheme: IconThemeData(color: AppColors.grey500),
        selectedLabelTextStyle: TextStyle(color: AppColors.secondary),
        unselectedLabelTextStyle: TextStyle(color: AppColors.grey500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.grey900,
        indicatorColor: AppColors.secondary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          scaledTextTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.grey300,
          ),
        ),
      ),

      // 9. Other Widgets
      dividerTheme: const DividerThemeData(
        color: AppColors.grey700,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary;
          }
          return AppColors.grey600;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary;
          }
          return AppColors.grey600;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary;
          }
          return AppColors.grey600;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary.withValues(alpha: 0.5);
          }
          return AppColors.grey800;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.secondary,
        inactiveTrackColor: AppColors.secondary.withValues(alpha: 0.3),
        thumbColor: AppColors.secondary,
        overlayColor: AppColors.secondary.withValues(alpha: 0.1),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey50,
        contentTextStyle: scaledTextTheme.bodyMedium?.copyWith(
          color: AppColors.grey900,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey800,
        disabledColor: AppColors.grey700,
        selectedColor: AppColors.secondary.withValues(alpha: 0.2),
        secondarySelectedColor: AppColors.secondary.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: scaledTextTheme.labelLarge?.copyWith(color: AppColors.darkOnSurface),
        secondaryLabelStyle: scaledTextTheme.labelLarge?.copyWith(color: AppColors.secondary),
        brightness: Brightness.dark,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.grey400,
        textColor: AppColors.darkOnSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.grey500,
        indicatorColor: AppColors.secondary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: scaledTextTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: scaledTextTheme.titleSmall,
      ),
    );
  }

  static TextTheme _scaleTextTheme(TextTheme textTheme, double multiplier) {
    return textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(fontSize: (textTheme.displayLarge?.fontSize ?? 57) * multiplier),
      displayMedium: textTheme.displayMedium?.copyWith(fontSize: (textTheme.displayMedium?.fontSize ?? 45) * multiplier),
      displaySmall: textTheme.displaySmall?.copyWith(fontSize: (textTheme.displaySmall?.fontSize ?? 36) * multiplier),
      headlineLarge: textTheme.headlineLarge?.copyWith(fontSize: (textTheme.headlineLarge?.fontSize ?? 32) * multiplier),
      headlineMedium: textTheme.headlineMedium?.copyWith(fontSize: (textTheme.headlineMedium?.fontSize ?? 28) * multiplier),
      headlineSmall: textTheme.headlineSmall?.copyWith(fontSize: (textTheme.headlineSmall?.fontSize ?? 24) * multiplier),
      titleLarge: textTheme.titleLarge?.copyWith(fontSize: (textTheme.titleLarge?.fontSize ?? 22) * multiplier),
      titleMedium: textTheme.titleMedium?.copyWith(fontSize: (textTheme.titleMedium?.fontSize ?? 16) * multiplier),
      titleSmall: textTheme.titleSmall?.copyWith(fontSize: (textTheme.titleSmall?.fontSize ?? 14) * multiplier),
      labelLarge: textTheme.labelLarge?.copyWith(fontSize: (textTheme.labelLarge?.fontSize ?? 14) * multiplier),
      labelMedium: textTheme.labelMedium?.copyWith(fontSize: (textTheme.labelMedium?.fontSize ?? 12) * multiplier),
      labelSmall: textTheme.labelSmall?.copyWith(fontSize: (textTheme.labelSmall?.fontSize ?? 11) * multiplier),
      bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: (textTheme.bodyLarge?.fontSize ?? 16) * multiplier),
      bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: (textTheme.bodyMedium?.fontSize ?? 14) * multiplier),
      bodySmall: textTheme.bodySmall?.copyWith(fontSize: (textTheme.bodySmall?.fontSize ?? 12) * multiplier),
    );
  }

  static final TextTheme _lightTextTheme =
      GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: AppColors.onBackground,
        displayColor: AppColors.onBackground,
      );

  static final TextTheme _darkTextTheme =
      GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.darkOnBackground,
        displayColor: AppColors.darkOnBackground,
      );
}
