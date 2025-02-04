import 'package:boss_app/pages/public_client/income_expense_pie_chart.dart';
import 'package:boss_app/pages/public_client/transaction_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:boss_app/components/bottom_nav.dart';
import 'package:boss_app/components/custom_header.dart';
import 'package:boss_app/pages/public_client/transaction_form.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late Future<List<QueryDocumentSnapshot>> _transactions;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _fetchTransactions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _transactions = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get()
          .then((snapshot) {
        return snapshot.docs;
      });
    } else {
      _transactions = Future.value([]);
    }
  }

  void _showEditMenu(
      BuildContext context, Map<String, dynamic> transactionData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionForm(
          initialTransactionType: transactionData['type'],
          initialAccount: transactionData['account'],
          initialCategory: transactionData['category'],
          initialAmount: transactionData['amount'].toString(),
          initialDate: (transactionData['date'] as Timestamp).toDate(),
          initialNotes: transactionData['notes'],
        ),
      ),
    );
  }

  void _deleteTransaction(String transactionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(transactionId)
            .delete();

        // Optionally show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully.')),
        );

        // Refresh the transactions list
        _fetchTransactions();
        setState(() {}); // Ensure the UI is updated after the deletion
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting transaction.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeader(
              title: 'Analysis',
              onLeadingIconPressed: () {
                // Handle leading icon press (e.g., navigate to profile)
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Income vs Expenses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const IncomeExpensePieChart(),
                    const SizedBox(height: 16),
                    const SizedBox(height: 24),
                    Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<QueryDocumentSnapshot>>(
                      future: _transactions,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(
                              child: Text("Error loading transactions."));
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text("No transactions made so far."));
                        }

                        final transactions = snapshot.data!;

                        return Column(
                          children: transactions.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final type = data['type'] ?? 'Income';
                            final notes =
                                data['notes'] ?? ''; // Default to 'Income'

                            return TransactionItem(
                              icon: Icons.account_balance_wallet,
                              title: data['category'] ?? 'Transaction',
                              amount: data['amount'] != null
                                  ? (data['amount'] as num).toInt()
                                  : 0,
                              date: (data['date'] as Timestamp).toDate(),
                              type: type,
                              notes: notes,
                              onEdit: () {
                                _showEditMenu(context, data);
                              },
                              onDelete: () {
                                _deleteTransaction(
                                    doc.id); // Use Firestore's document ID
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/expenses'); // Close the dialog
        },
        child: Icon(Icons.add),
        tooltip: 'Add Transaction',
      ),
    );
  }
}
