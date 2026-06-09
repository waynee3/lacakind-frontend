import 'package:flutter/material.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';

class LabelDropdown<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool enabled;

  const LabelDropdown({
    super.key,
    required this.label,
    required this.items,
    this.hintText,
    this.value,
    this.onChanged,
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
          style: textTheme.bodyMedium?.regular,
        ),
        const SizedBox(height: 4),
        InputDecorator(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: enabled ? onChanged : null,
              hint: hintText != null
                  ? Text(hintText!, style: textTheme.bodyMedium?.regular)
                  : null,
              isExpanded: true,
              style: textTheme.bodyMedium?.regular,
            ),
          ),
        ),
      ],
    );
  }
}
