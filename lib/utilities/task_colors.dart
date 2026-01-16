import 'package:flutter/material.dart';

class TaskColors {
  static const List<Color> palette = [
    Color(0xFF2196F3), // Blue
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
  ];

  static String getColorName(int colorValue) {
    final color = Color(colorValue);
    if (color.value == palette[0].value) return 'Blue';
    if (color.value == palette[1].value) return 'Pink';
    if (color.value == palette[2].value) return 'Purple';
    if (color.value == palette[3].value) return 'Green';
    if (color.value == palette[4].value) return 'Orange';
    if (color.value == palette[5].value) return 'Red';
    if (color.value == palette[6].value) return 'Cyan';
    if (color.value == palette[7].value) return 'Yellow';
    if (color.value == palette[8].value) return 'Brown';
    if (color.value == palette[9].value) return 'Grey';
    return 'Blue';
  }
}
