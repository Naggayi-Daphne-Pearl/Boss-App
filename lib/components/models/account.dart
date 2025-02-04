import 'package:flutter/material.dart';

class Account {
  final String id;
  final String name;
  final double initialAmount;
  final double balance;
  final IconData icon;
  final String currency;

  Account({
    required this.id,
    required this.name,
    required this.initialAmount,
    required this.balance,
    required this.icon,
    required this.currency,
  });
}
