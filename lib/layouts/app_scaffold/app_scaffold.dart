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
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          "LacakInd",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SizedBox.expand(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: double.infinity,
              width: 280,
              child: SingleChildScrollView(
                child: const AppDrawer(),
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: neutral200),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
