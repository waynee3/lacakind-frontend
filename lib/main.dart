import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:scaled_app/scaled_app.dart';

const double heightOfDesign = 640;
const double widthOfDesign = 360;

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
      theme: ThemeData(
        textTheme: GoogleFonts.dmSansTextTheme(),
      ),
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
    );
  }
}
