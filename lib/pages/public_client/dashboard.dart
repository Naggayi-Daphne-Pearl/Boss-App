import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:boss_app/components/bottom_nav.dart';
import 'package:boss_app/components/custom_header_white.dart';
import 'package:boss_app/providers/user_provider.dart';
import 'package:boss_app/pages/public_client/transaction_form.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserProvider>(context).user ?? "User";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeaderWhite(
              title: 'Welcome Boss $username',
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
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error loading net worth."));
                      }

                      final netWorth = snapshot.data ?? 0.0;

                      return NetWorthCard(netWorth: netWorth);
                    },
                  ),
                  SizedBox(height: 16),
                  SizedBox(height: 16),
                  FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: _transactions,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error loading transactions."),
                        );
                      }

                      final transactions = snapshot.data;

                      if (transactions == null || transactions.isEmpty) {
                        return Center(
                          child: Text("No transactions available."),
                        );
                      }

                      return Column(
                        children: transactions.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return TransactionItem(
                            icon: Icons.account_balance_wallet,
                            title: data['category'] ?? 'Transaction',
                            amount: data['amount'] ?? 0,
                            date: (data['date'] as Timestamp).toDate(),
                            type: data['type'] ?? 'Income',
                          );
                        }).toList(),
                      );
                    },
                  ),
                  Center(
                    child: TextButton(onPressed: () {}, child: Text('See all')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => TransactionForm(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NetWorthCard extends StatelessWidget {
  final double netWorth;

  const NetWorthCard({required this.netWorth});

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Your Net Worth',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'UGX ${netWorth.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 16),
            NetWorthDetails(),
          ],
        ),
      ),
    );
  }
}

class NetWorthDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            NetWorthInfo(title: 'Your Position', value: '+20,000,000'),
            VerticalDivider(color: Colors.grey),
            NetWorthInfo(title: 'Rank Position', value: '+10th Position'),
          ],
        ),
      ),
    );
  }
}

class NetWorthInfo extends StatelessWidget {
  final String title;
  final String value;

  const NetWorthInfo({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int amount;
  final DateTime date;
  final String type;

  const TransactionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  String formatDate(DateTime date) {
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    Color amountColor = type == 'Expense' ? Colors.red : Colors.green;
    String formattedAmount =
        type == 'Expense' ? '-${amount.toString()}' : amount.toString();

    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade900),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(
        formattedAmount,
        style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(formatDate(date)),
    );
  }
}
