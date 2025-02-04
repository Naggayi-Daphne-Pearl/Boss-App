import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IncomeExpensePieChart extends StatelessWidget {
  const IncomeExpensePieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          "Please log in to view the chart.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Error loading chart data.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No data available.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }

        final transactions = snapshot.data!.docs;
        double incomeTotal = 0;
        double expenseTotal = 0;

        // Calculate totals by type
        for (var doc in transactions) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['amount'] ?? 0).toDouble();
          final type = (data['type'] ?? '').toString();

          switch (type) {
            case 'Income':
              incomeTotal += amount;
              break;
            case 'Expense':
              expenseTotal += amount;
              break;
          }
        }

        final total = incomeTotal + expenseTotal;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pie chart
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          sections: _buildPieChartSections(
                            incomeTotal,
                            expenseTotal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          color: Colors.green.shade700,
                          label: "Income",
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          color: Colors.red.shade700,
                          label: "Expense",
                        ),
                        const SizedBox(height: 8),
                        // _buildLegendItem(
                        //   color: Colors.blue.shade700,
                        //   label: "Transfer",
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Total amount
              Text(
                "Total: ${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    double incomeTotal,
    double expenseTotal,
    // double transferTotal,
  ) {
    final total = incomeTotal + expenseTotal;

    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: 'No Data',
          radius: 60,
          titleStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ];
    }

    return [
      _buildSectionData(
        color: Colors.green.shade700,
        value: incomeTotal,
        total: total,
        label: 'Income',
      ),
      _buildSectionData(
        color: Colors.red.shade700,
        value: expenseTotal,
        total: total,
        label: 'Expense',
      ),
    ];
  }

  PieChartSectionData _buildSectionData({
    required Color color,
    required double value,
    required double total,
    required String label,
  }) {
    final percentage = (value / total) * 100;

    return PieChartSectionData(
      color: color,
      value: percentage,
      title: '${percentage.toStringAsFixed(1)}%',
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
