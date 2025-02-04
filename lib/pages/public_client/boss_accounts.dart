import 'package:boss_app/components/bottom_nav.dart';
import 'package:boss_app/components/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:boss_app/components/models/account.dart';
import 'package:boss_app/components/models/account_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:boss_app/providers/net_worth_provider.dart';
import 'package:intl/intl.dart';

class AccountsPage extends StatefulWidget {
  @override
  _AccountsPageState createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Account> accounts = [];
  List<String> currencyOptions = ['UGX', 'USD', 'EUR', 'GBP'];
  String selectedCurrency = 'UGX';

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final accountDocs = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('accounts')
            .get();

        // Check if the user has any accounts
        if (accountDocs.docs.isEmpty) {
          // Create default accounts
          await _addDefaultAccounts(user.uid);
        }

        setState(() {
          accounts = accountDocs.docs.map((doc) {
            final data = doc.data();
            return Account(
              id: doc.id,
              icon: Icons.account_balance,
              name: data['name'],
              initialAmount: (data['initialAmount'] as num).toDouble(), // Explicit conversion
              balance: (data['balance'] ?? data['initialAmount'] as num).toDouble(),
              currency: data['currency'],
            );
          }).toList();
        });

        // Calculate total net worth
        double totalNetWorth =
            accounts.fold(0, (sum, acc) => sum + acc.initialAmount);
        Provider.of<NetWorthProvider>(context, listen: false)
            .updateNetWorth(totalNetWorth);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching accounts: $e')),
      );
    }
  }

  Future<void> _addDefaultAccounts(String userId) async {
    final defaultAccounts = [
      {
        'name': 'Bank Account',
        'initialAmount': 1.0,
        'balance': 1.0,
        'icon': Icons.account_balance.codePoint,
        'currency': 'UGX',
      },
      {
        'name': 'Savings Account',
        'initialAmount': 1.0,
        'balance': 1.0,
        'icon': Icons.savings.codePoint,
        'currency': 'UGX',
      },
    ];

    for (var account in defaultAccounts) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .add(account);
    }
  }

  Future<void> _addAccountToFirestore(
      String name, double initialAmount, IconData icon, String currency) async {
    final user = _auth.currentUser;
    if (user != null) {
      final accountData = {
        'name': name,
        'initialAmount': initialAmount,
        'balance': initialAmount,
        'icon': icon.codePoint,
        'currency': currency,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('accounts')
          .add(accountData);

      setState(() {
        accounts.add(Account(
          id: UniqueKey().toString(),
          icon: icon,
          name: name,
          initialAmount: initialAmount,
          balance: initialAmount,
          currency: selectedCurrency,
        ));
      });

      await _saveAccountToLocal(name, initialAmount);
      Provider.of<NetWorthProvider>(context, listen: false)
          .updateNetWorth(initialAmount);
    }
  }

  Future<void> _saveAccountToLocal(String name, double initialAmount) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> accountList = prefs.getStringList('accounts') ?? [];
    accountList.add('$name,$initialAmount');
    await prefs.setStringList('accounts', accountList);
  }

  void _showAddAccountDialog() {
    String? accountName;
    double? initialAmount;
    IconData selectedIcon = Icons.account_balance;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Account Name'),
                    onChanged: (value) {
                      accountName = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(labelText: 'Initial Amount'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      initialAmount = double.tryParse(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedCurrency,
                    items: currencyOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCurrency = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(Icons.account_balance),
                        onPressed: () {
                          setState(() {
                            selectedIcon = Icons.account_balance;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.account_balance_wallet),
                        onPressed: () {
                          setState(() {
                            selectedIcon = Icons.account_balance_wallet;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.savings),
                        onPressed: () {
                          setState(() {
                            selectedIcon = Icons.savings;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (accountName != null &&
                        accountName!.isNotEmpty &&
                        initialAmount != null) {
                      _addAccountToFirestore(accountName!, initialAmount!,
                          selectedIcon, selectedCurrency);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDeleteDialog(Account account) {
    String? accountName = account.name;
    double? initialAmount = account.initialAmount;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Account Name'),
                onChanged: (value) {
                  accountName = value;
                },
                controller: TextEditingController(text: account.name),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Initial Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  initialAmount = double.tryParse(value);
                },
                controller: TextEditingController(
                    text: account.initialAmount.toString()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (accountName != null &&
                    accountName!.isNotEmpty &&
                    initialAmount != null) {
                  _updateAccountInFirestore(account.id, accountName!,
                      initialAmount!, account.currency);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                _deleteAccountFromFirestore(account.id);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAccountInFirestore(String accountId, String name,
      double initialAmount, String currency) async {
    final user = _auth.currentUser;
    if (user != null) {
      final accountData = {
        'name': name,
        'initialAmount': initialAmount,
        'balance': initialAmount,
        'currency': currency,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('accounts')
          .doc(accountId)
          .update(accountData);

      // Update the local accounts list
      setState(() {
        final index = accounts.indexWhere((acc) => acc.id == accountId);
        if (index != -1) {
          accounts[index] = Account(
            id: accountId,
            icon: accounts[index].icon,
            name: name,
            initialAmount: initialAmount,
            balance: initialAmount,
            currency: currency,
          );
        }
      });
    }
  }

  Future<void> _deleteAccountFromFirestore(String accountId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('accounts')
          .doc(accountId)
          .delete();

      // Update the local accounts list
      setState(() {
        accounts.removeWhere((acc) => acc.id == accountId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomHeader(
            title: 'Your Accounts',
            onLeadingIconPressed: () {},
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: accounts.isEmpty
                  ? Center(child: Text('No accounts found.'))
                  : ListView.builder(
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        return AccountItem(
                          icon: account.icon,
                          name: account.name,
                          initialAmount: account.initialAmount,
                          balance: account.balance,
                          currency: account.currency,
                          onEditDelete: () => _showEditDeleteDialog(account),
                        );
                      },
                    ),
            ),
          ),
          _buildAddAccountsButton(),
        ],
      ),
      bottomNavigationBar: BottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/expenses'); // Close the dialog
        },
        child: Icon(Icons.add),
        tooltip: 'Add Transaction',
      ),
    );
  }

  Widget _buildAddAccountsButton() {
    return Center(
      child: TextButton(
        onPressed: _showAddAccountDialog,
        child: const Text('ADD ACCOUNT'),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          textStyle: const TextStyle(fontSize: 16),
          side: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
