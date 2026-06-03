import "package:flutter/material.dart";

extension TextExt on TextStyle? {
  TextStyle? get italic {
    return this?.copyWith(fontStyle: FontStyle.italic);
  }

  TextStyle? get regular {
    return this?.copyWith(fontWeight: FontWeight.w400);
  }

  TextStyle? get medium {
    return this?.copyWith(fontWeight: FontWeight.w500);
  }

  TextStyle? get semibold {
    return this?.copyWith(fontWeight: FontWeight.w600);
  }

  TextStyle? get bold {
    return this?.copyWith(fontWeight: FontWeight.w700);
  }

  TextStyle? withColor(Color color) {
    return this?.copyWith(color: color);
  }
}
