import 'package:flutter/material.dart';

class CardItem {
  final IconData icon;
  final String label;
  final bool showPadlock;
  final String route;

  CardItem({
    required this.icon,
    required this.label,
    this.showPadlock = false,
    required this.route,
  });
}
