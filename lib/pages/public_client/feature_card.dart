import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showPadlock;
  final String route;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.label,
    required this.showPadlock,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!showPadlock) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade500,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          if (showPadlock)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.lock, color: Colors.blue.shade900, size: 20),
            ),
        ],
      ),
    );
  }
}
