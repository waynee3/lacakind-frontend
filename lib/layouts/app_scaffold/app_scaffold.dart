import 'package:flutter/material.dart';
import 'package:lacakind_frontend/layouts/app_scaffold/widget/app_drawer.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: baseWhite,
      appBar: AppBar(
        backgroundColor: baseWhite,
        elevation: 0,
        title: const Text(
          "LacakInd",
          style: TextStyle(
            color: baseBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SizedBox.expand(child: Row(
        children: [
          const AppDrawer(),
          Expanded(child: child),
        ],
      )),
    );
  }
}
