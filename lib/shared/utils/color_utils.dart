import 'package:flutter/material.dart';

Color parseHexColor(String colorCode, {Color? fallback}) {
  try {
    final cleaned = colorCode.trim();
    if (cleaned.isEmpty) return fallback ?? Colors.grey;
    final code = cleaned.startsWith('#')
        ? cleaned.replaceFirst('#', '0xFF')
        : (cleaned.startsWith('0x') ? cleaned : '0xFF$cleaned');
    return Color(int.parse(code));
  } catch (_) {
    return fallback ?? Colors.grey;
  }
}
