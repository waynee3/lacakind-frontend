import 'package:flutter/material.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';
import 'package:scaled_app/scaled_app.dart';

const double heightOfDesign = 1080;
const double widthOfDesign = 1920;

void main() {
  ScaledWidgetsFlutterBinding.ensureInitialized(
    scaleFactor: (deviceSize) {
      double scaleWidth = deviceSize.width / widthOfDesign;
      double scaleHeight = deviceSize.height / heightOfDesign;
      return scaleWidth < scaleHeight ? scaleWidth : scaleHeight;
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "LacakInd",
      theme: ThemeData(
        textTheme: _textTheme,
        fontFamily: "DM Sans",
        scaffoldBackgroundColor: baseWhite,
        useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderSide: BorderSide(color: neutral200)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: neutral200)),
            hintStyle: _textTheme.bodyMedium?.withColor(neutral500),
          ),
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
                  backgroundColor: baseBlack,
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
      ),
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
    );
  }
}

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

