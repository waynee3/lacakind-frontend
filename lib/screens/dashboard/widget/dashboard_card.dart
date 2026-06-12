import 'package:flutter/material.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  const DashboardCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title, style: textTheme.titleSmall?.semibold),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}
