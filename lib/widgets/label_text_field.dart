import 'package:flutter/material.dart';

import '../theme/qios_color.dart';

class LabelTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool? obscureText;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;

  const LabelTextField({
    super.key,
    required this.label,
    this.hintText,
    this.suffixIcon,
    this.controller,
    this.obscureText,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: neutral900, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderSide: BorderSide(color: neutral200)),
            hintStyle: textTheme.bodyMedium?.copyWith(color: neutral500, fontWeight: FontWeight.w400),
          ),
          maxLines: maxLines,
          controller: controller,
          obscureText: obscureText ?? false,
          style: textTheme.bodyMedium?.copyWith(color: neutral900, fontWeight: FontWeight.w400),
          onChanged: onChanged,
          enabled: enabled,
        ),
      ],
    );
  }
}
