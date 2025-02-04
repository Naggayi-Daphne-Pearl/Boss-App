import 'package:boss_app/pages/public_client/main_menu.dart';
import 'package:boss_app/pages/public_client/net_worth_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NetWorthCard extends StatelessWidget {
  final double netWorth;
  final Future<List<QueryDocumentSnapshot>> transactions;

  const NetWorthCard(
      {super.key, required this.netWorth, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your Net Worth',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'UGX ${formatter.format(netWorth)}',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            NetWorthDetails(transactions: transactions),
          ],
        ),
      ),
    );
  }
}
