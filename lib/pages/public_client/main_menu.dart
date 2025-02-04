import 'package:boss_app/components/bottom_nav.dart';
import 'package:boss_app/components/custom_header_white.dart';
import 'package:boss_app/pages/public_client/card_item.dart';
import 'package:boss_app/pages/public_client/feature_card.dart';
import 'package:boss_app/pages/public_client/feature_grid.dart';
import 'package:boss_app/pages/public_client/net_worth_card.dart';
import 'package:boss_app/pages/public_client/net_worth_info.dart';
import 'package:boss_app/pages/public_client/transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:boss_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:boss_app/pages/public_client/transaction_item.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenu> {
  late Future<List<QueryDocumentSnapshot>> _transactions;
  late Future<double> _netWorth;
  @override
  void initState() {
    super.initState();
    _transactions = _fetchTransactions();
    _netWorth = _fetchNetWorth();
  }

  Future<List<QueryDocumentSnapshot>> _fetchTransactions() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs;
  }

  Future<double> _fetchNetWorth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 0.0;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('accounts') // Fetch from accounts collection
        .get();

    double totalBalance = 0.0;
    for (var doc in snapshot.docs) {
      totalBalance += (doc.data()['balance'] ?? 0.0); // Sum up balances
    }

    return totalBalance; // Return total net worth
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
    final username = Provider.of<UserProvider>(context).user ?? "User";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeaderWhite(
              title: 'Welcome Boss, $username',
              onLeadingIconPressed: () {
                // Handle leading icon press (e.g., navigate to profile)
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<double>(
                    future: _netWorth,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                            child: Text("Error loading net worth."));
                      }

                      final netWorth = snapshot.data ?? 0.0;

                      return NetWorthCard(
                          netWorth: netWorth, transactions: _transactions);
                    },
                  ),
                  const SizedBox(height: 16),
                  const FeatureGrid(),
                  const SizedBox(height: 16),
                  FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: _transactions,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error loading transactions."),
                        );
                      }

                      final transactions = snapshot.data;

                      if (transactions == null || transactions.isEmpty) {
                        return const Center(
                          child: Text("No transactions available."),
                        );
                      }

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
                  Center(
                    child: TextButton(
                        onPressed: () {}, child: const Text('See all')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const TransactionForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

List<CardItem> cardItems = [
  CardItem(icon: Icons.book, label: 'Expenses', route: '/expenses'),
  CardItem(icon: Icons.credit_card, label: 'Income', route: '/expenses'),
  CardItem(
      icon: Icons.grid_4x4,
      label: 'Liabilities',
      showPadlock: true,
      route: '/liabilities'),
  CardItem(
      icon: Icons.shop,
      label: 'Crowd Funding',
      showPadlock: true,
      route: '/crowdfunding'),
  CardItem(
      icon: Icons.storage,
      label: 'Assets',
      showPadlock: true,
      route: '/assests'),
  CardItem(
      icon: Icons.bar_chart,
      label: 'Ranking',
      showPadlock: true,
      route: '/ranking'),
  CardItem(icon: Icons.bookmark_added, label: 'Money Forum', route: '/forum'),
];
