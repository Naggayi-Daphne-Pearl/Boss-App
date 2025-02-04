import 'package:boss_app/pages/public_client/feature_card.dart';
import 'package:boss_app/pages/public_client/main_menu.dart';
import 'package:flutter/material.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.blue.shade100,
      ),
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 0.85,
        ),
        itemCount: cardItems.length,
        itemBuilder: (context, index) {
          final item = cardItems[index];
          return FeatureCard(
            icon: item.icon,
            label: item.label,
            showPadlock: item.showPadlock,
            route: item.route,
          );
        },
      ),
    );
  }
}
