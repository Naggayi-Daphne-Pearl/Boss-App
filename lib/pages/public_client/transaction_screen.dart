import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatelessWidget {
  final String category;
  final IconData icon;

  const TransactionScreen({
    required this.category,
    required this.icon,
    Key? key,
  }) : super(key: key);

  // Helper to format timestamps
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    final DateTime date = timestamp.toDate();
    return DateFormat.yMMMMd().add_jm().format(date);
  }

  // Helper to format amounts
  String formatAmount(double amount) {
    final format = NumberFormat('#,##0', 'en_US'); // Formats with commas
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('$category'),
          backgroundColor: Colors.blue.shade900,
        ),
        body: Center(
          child: Text(
            'Please log in to view transactions.',
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions for $category'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final transactions = snapshot.data!.docs;
          double totalIncome = 0.0;
          double totalExpense = 0.0;

          // Calculate total income and expenses
          for (var transaction in transactions) {
            final data = transaction.data() as Map<String, dynamic>;
            final amount = data['amount']?.toDouble() ?? 0.0;
            if (data['type'] == 'Income') {
              totalIncome += amount;
            } else {
              totalExpense += amount;
            }
          }

          return Column(
            children: [
              _buildSummary(totalIncome, totalExpense), // New summary widget
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final data =
                        transactions[index].data() as Map<String, dynamic>;
                    return _buildTransactionCard(data);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Transactions for $category',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Start adding transactions in the $category category.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> data) {
    final String type = data['type'] ?? 'Unknown';
    final String account = data['account'] ?? 'No Account';
    final String notes = data['notes'] ?? 'No Notes';
    final double amount = data['amount']?.toDouble() ?? 0.0;
    final String formattedAmount = formatAmount(amount);
    final String formattedDate = formatDate(data['date']);
    final Color typeColor = type == 'Income' ? Colors.green : Colors.red;
    final IconData typeIcon =
        type == 'Income' ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(typeIcon, color: typeColor),
        title:
            Text(account, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: UGX $formattedAmount'),
            Text('Notes: $notes'),
            Text('Date: $formattedDate'),
          ],
        ),
        trailing: Text(
          type,
          style: TextStyle(color: typeColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSummary(double totalIncome, double totalExpense) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Total Money Earned: UGX ${formatAmount(totalIncome)}',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          Text(
            'Total Money Spent: UGX ${formatAmount(totalExpense)}',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
