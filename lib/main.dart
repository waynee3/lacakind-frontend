import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/core/api_client.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/styles/theme_cubit.dart';
import 'package:scaled_app/scaled_app.dart';

const double widthOfDesign = 1920;

void main() async {
  ScaledWidgetsFlutterBinding.ensureInitialized(
    scaleFactor: (deviceSize) => deviceSize.width / widthOfDesign,
  );

  ApiClient.init();

  runApp(
    BlocProvider(
      create: (_) => ThemeCubit(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          title: "LacakInd",
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
          routerDelegate: router.routerDelegate,
        );
      },
    );
  }
}