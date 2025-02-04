import 'package:flutter/material.dart';

class Legend extends StatelessWidget {
  const Legend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Container(width: 16, height: 16, color: Colors.blue.shade900),
              const SizedBox(width: 8),
              Text('Income', style: TextStyle(color: Colors.blue.shade900)),
            ],
          ),
          Row(
            children: [
              Container(width: 16, height: 16, color: Colors.red),
              const SizedBox(width: 8),
              Text('Expenses', style: TextStyle(color: Colors.blue.shade900)),
            ],
          ),
        ],
      ),
    );
  }
}
