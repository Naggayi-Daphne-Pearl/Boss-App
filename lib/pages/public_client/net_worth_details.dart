import 'package:boss_app/pages/public_client/net_worth_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NetWorthDetails extends StatelessWidget {
  final Future<List<QueryDocumentSnapshot>> transactions;

  const NetWorthDetails({super.key, required this.transactions});

  Future<double> _calculateTotalExpenses() async {
    double totalExpenses = 0.0;
    final transactionDocs = await transactions;

    for (var doc in transactionDocs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['type'] == 'Expense') {
        totalExpenses += data['amount'] ?? 0.0;
      }
    }
    return totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');

    return FutureBuilder<double>(
      future: _calculateTotalExpenses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading expenses."));
        }

        final totalExpenses = snapshot.data ?? 0.0;

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NetWorthInfo(
                    title: 'Total Expenses',
                    value: '-${formatter.format(totalExpenses)}'),
                // VerticalDivider(color: Colors.grey),
                // NetWorthInfo(title: 'Rank Position', value: '+10th Position'),
              ],
            ),
          ),
        );
      },
    );
  }
}
