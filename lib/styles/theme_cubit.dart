import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? false;
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      debugPrint("Could not load theme: $e");
      emit(ThemeMode.light);
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newMode == ThemeMode.dark);

    emit(newMode);
  }
}

final lightTheme = ThemeData(
  fontFamily: "DM Sans",
  useMaterial3: true,
  brightness: Brightness.light,
  canvasColor: baseWhite,
  primaryColor: baseWhite,
  scaffoldBackgroundColor: baseWhite,
  cardTheme: CardThemeData(
    color: neutral50,
    shadowColor: neutral900.withValues(alpha: 0.1),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return baseBlack;
      }
      if (states.contains(WidgetState.disabled)) {
        return baseWhite;
      }
      return null;
    }),
  ),
  iconTheme: const IconThemeData(color: Colors.black54),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: baseBlack,
      foregroundColor: baseWhite,
    ),
  ),
  dividerColor: neutral600.withValues(alpha: 0.2),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: baseBlack),
    hintStyle: TextStyle(color: neutral600),
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: neutral600),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: baseBlack, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  ),
  textTheme: _textTheme,
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: baseBlack,
      foregroundColor: baseWhite,
      disabledBackgroundColor: neutral200,
      disabledForegroundColor: neutral600,
      textStyle: _textTheme.bodyLarge?.medium,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style:
        OutlinedButton.styleFrom(
          side: BorderSide(color: baseBlack),
          foregroundColor: baseBlack,
          disabledBackgroundColor: neutral200,
          disabledForegroundColor: neutral800,
          textStyle: _textTheme.bodyLarge?.medium,
        ).copyWith(
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: neutral300);
            }
            return BorderSide(color: baseBlack);
          }),
        ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: baseBlack,
      disabledForegroundColor: neutral600,
      textStyle: _textTheme.bodyLarge?.medium,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: baseWhite,
    foregroundColor: baseBlack,
  ),
  primaryIconTheme: const IconThemeData(color: baseBlack),
  dialogTheme: DialogThemeData(
    backgroundColor: baseWhite,
    titleTextStyle: _textTheme.headlineMedium?.bold,
    contentTextStyle: _textTheme.bodyMedium,
    shadowColor: neutral200,
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: _textTheme.bodyMedium?.regular?.copyWith(color: baseBlack),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: baseBlack),
      hintStyle: TextStyle(color: neutral600),
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: neutral600),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: baseBlack, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(baseWhite),
      elevation: WidgetStateProperty.all(4),
      shadowColor: WidgetStateProperty.all(baseBlack),
    ),
  ),
);

final darkTheme = ThemeData(
  fontFamily: "DM Sans",
  useMaterial3: true,
  brightness: Brightness.dark,
  canvasColor: baseBlack,
  primaryColor: baseWhite,
  scaffoldBackgroundColor: baseBlack,
  cardTheme: CardThemeData(
    color: neutral800,
    shadowColor: neutral900.withValues(alpha: 0.1),
  ),
  textTheme: _textTheme,
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return baseWhite;
      }
      if (states.contains(WidgetState.disabled)) {
        return baseWhite;
      }
      return null;
    }),
  ),
  iconTheme: const IconThemeData(color: Colors.white60),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: baseWhite,
      foregroundColor: baseBlack,
    ),
  ),
  dividerColor: neutral200.withValues(alpha: 0.2),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: baseWhite),
    hintStyle: TextStyle(color: neutral200),
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: neutral200),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: neutral600, width: 2),
    ),
    fillColor: baseWhite,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: baseWhite,
      foregroundColor: baseBlack,
      disabledBackgroundColor: neutral200,
      disabledForegroundColor: neutral600,
      textStyle: _textTheme.bodyLarge?.medium,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style:
        OutlinedButton.styleFrom(
          side: BorderSide(color: baseWhite),
          foregroundColor: baseWhite,
          disabledBackgroundColor: neutral200,
          disabledForegroundColor: neutral800,
          textStyle: _textTheme.bodyLarge?.medium,
        ).copyWith(
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: neutral300);
            }
            return BorderSide(color: baseWhite);
          }),
        ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: baseWhite,
      disabledForegroundColor: neutral600,
      textStyle: _textTheme.bodyLarge?.medium,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: baseBlack,
    foregroundColor: baseWhite,
  ),
  primaryIconTheme: const IconThemeData(color: baseWhite),
  dialogTheme: DialogThemeData(
    backgroundColor: baseBlack,
    titleTextStyle: _textTheme.headlineMedium?.bold,
    contentTextStyle: _textTheme.bodyMedium,
    shadowColor: neutral600,
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: _textTheme.bodyMedium?.regular?.copyWith(color: baseWhite),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: baseWhite),
      hintStyle: TextStyle(color: neutral200),
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: neutral200),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: baseWhite, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(baseWhite),
      elevation: WidgetStateProperty.all(4),
      shadowColor: WidgetStateProperty.all(baseWhite),
    ),
  ),
);

final _textTheme = TextTheme(
  displayLarge: const TextStyle(fontSize: 60, height: 1.2),
  displayMedium: const TextStyle(fontSize: 48, height: 1.2),
  displaySmall: const TextStyle(fontSize: 36, height: 1.2),
  headlineLarge: const TextStyle(fontSize: 30, height: 40 / 30),
  headlineMedium: const TextStyle(fontSize: 28, height: 36 / 28),
  headlineSmall: const TextStyle(fontSize: 24, height: 32 / 24),
  titleLarge: const TextStyle(fontSize: 22, height: 32 / 22),
  titleMedium: const TextStyle(fontSize: 20, height: 32 / 20),
  titleSmall: const TextStyle(fontSize: 18, height: 28 / 18),
  bodyLarge: const TextStyle(fontSize: 16, height: 24 / 16),
  bodyMedium: const TextStyle(fontSize: 14, height: 20 / 14),
  bodySmall: const TextStyle(fontSize: 12, height: 16 / 12),
);
