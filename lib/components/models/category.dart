import 'package:flutter/material.dart';

class Category {
  String label;
  IconData icon;
  Color color;
  bool isIncome;
  String id;

  Category({
    required this.label,
    required this.icon,
    required this.color,
    required this.isIncome,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'icon': icon.codePoint,
      'color': color.value,
      'isIncome': isIncome,
      'id': id,
    };
  }

  static Category fromMap(Map<String, dynamic> map, String id) {
    return Category(
      label: map['label'],
      icon: IconData(
        map['icon'],
        fontFamily: 'MaterialIcons',
      ),
      color: Color(map['color']),
      isIncome: map['isIncome'],
      id: id,
    );
  }

  // Method to update category properties
  void update({
    String? newLabel,
    IconData? newIcon,
    Color? newColor,
    bool? newIsIncome,
  }) {
    if (newLabel != null) label = newLabel;
    if (newIcon != null) icon = newIcon;
    if (newColor != null) color = newColor;
    if (newIsIncome != null) isIncome = newIsIncome;
  }
}
