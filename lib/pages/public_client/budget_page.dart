import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:boss_app/components/bottom_nav.dart';
import 'package:boss_app/components/custom_header.dart';
import 'package:boss_app/components/models/category.dart';
import 'package:intl/intl.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  List<Map<String, dynamic>> categoriesWithBudgets = [];
  List<Category> categoriesWithoutBudgets = [];
  List<Category> categories = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndBudgets();
  }

  final Map<String, IconData> predefinedIcons = {
    'home': Icons.home,
    'work': Icons.work,
    'food': Icons.fastfood,
  };

  Future<void> _fetchCategoriesAndBudgets() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final categoryDocs = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('categories')
            .where('isIncome', isEqualTo: false)
            .get();

        final budgetDocs = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('budgets')
            .get();

        final budgetData = Map.fromEntries(budgetDocs.docs.map((doc) {
          final data = doc.data();
          return MapEntry(data['category'], data);
        }));

        setState(() {
          categoriesWithBudgets = [];
          categoriesWithoutBudgets = [];
          categories = []; // Reset categories list

          for (var doc in categoryDocs.docs) {
            final data = doc.data();
            final category = Category(
              id: doc.id,
              icon: predefinedIcons[data['icon']] ?? Icons.category,
              color: Color(data['color']),
              isIncome: data['isIncome'],
              label: data['label'],
            );

            categories.add(category); // Add to categories list for rendering

            if (budgetData.containsKey(category.label)) {
              categoriesWithBudgets.add({
                'category': category,
                'budget': budgetData[category.label],
              });
            } else {
              categoriesWithoutBudgets.add(category);
            }
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error fetching data: ${e.toString()}');
    }
  }

  Future<double> _calculateTotalSpent(String category) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final transactionDocs = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .where('type', isEqualTo: 'Expense')
            .where('category', isEqualTo: category)
            .get();

        double totalSpent = transactionDocs.docs.fold(0.0, (sum, doc) {
          final data = doc.data();
          return sum + (data['amount'] ?? 0.0);
        });

        return totalSpent;
      }
    } catch (e) {
      _showSnackBar('Error calculating total spent: ${e.toString()}');
    }
    return 0.0;
  }

  Future<void> _addBudget(String category, double budgetLimit) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('budgets')
            .add({
          'category': category,
          'limit': budgetLimit,
          'spent': 0.0,
        });

        _showSnackBar('Budget added successfully!');
        _fetchCategoriesAndBudgets(); // Refresh the data
      }
    } catch (e) {
      _showSnackBar('Error adding budget: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showBudgetDialog(String category, {double? currentBudget}) {
    double? budgetLimit = currentBudget;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(currentBudget == null
              ? 'Set Budget for $category'
              : 'Edit Budget for $category'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Budget Limit'),
            keyboardType: TextInputType.number,
            controller:
                TextEditingController(text: budgetLimit?.toString() ?? ''),
            onChanged: (value) => budgetLimit = double.tryParse(value),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (budgetLimit != null) {
                  currentBudget == null
                      ? _addBudget(category, budgetLimit!)
                      : _updateBudget(category, budgetLimit!);
                  Navigator.of(context).pop();
                } else {
                  _showSnackBar('Please enter a valid budget limit.');
                }
              },
              child:
                  Text(currentBudget == null ? 'Set Budget' : 'Update Budget'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBudget(String category, double newBudget) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final budgetQuery = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('budgets')
            .where('category', isEqualTo: category)
            .get();

        if (budgetQuery.docs.isNotEmpty) {
          final budgetDoc = budgetQuery.docs.first;
          await budgetDoc.reference.update({
            'limit': newBudget,
          });

          _showSnackBar('Budget updated successfully!');
          _fetchCategoriesAndBudgets(); // Refresh the data
        }
      }
    } catch (e) {
      _showSnackBar('Error updating budget: ${e.toString()}');
    }
  }

  void _deleteBudget(String category) async {
    final user = FirebaseAuth.instance.currentUser;

    // Show the confirmation dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Budget?'),
          content: const Text(
              'Are you sure you want to remove the budget for this category?'),
          actions: [
            TextButton(
              onPressed: () async {
                if (user != null) {
                  try {
                    // Get the document reference for the budget category
                    var budgetSnapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('budgets')
                        .where('category', isEqualTo: category)
                        .get();

                    // Check if we found a matching document
                    if (budgetSnapshot.docs.isNotEmpty) {
                      // Get the first document (assuming only one document matches the category)
                      var budgetDoc = budgetSnapshot.docs.first;

                      // Delete the budget document from Firestore
                      await budgetDoc.reference.delete();

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Budget deleted successfully.')),
                      );
                      _fetchCategoriesAndBudgets();
                    } else {
                      // Show error message if no matching document is found
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('No budget found for this category.')),
                      );
                    }

                    // Close the dialog
                    Navigator.pop(context);
                  } catch (e) {
                    // Handle any errors during the deletion process
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting budget: $e')),
                    );

                    // Close the dialog
                    Navigator.pop(context);
                  }
                } else {
                  // If user is not logged in, show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User not authenticated')),
                  );

                  // Close the dialog
                  Navigator.pop(context);
                }
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog without performing any action
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomHeader(
            title: 'Boss Budgets',
            onLeadingIconPressed: () {},
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: categoriesWithBudgets.isEmpty &&
                      categoriesWithoutBudgets.isEmpty
                  ? const Center(child: Text('No categories available'))
                  : ListView(
                      children: [
                        // Display categories with budgets first
                        ...categoriesWithBudgets.map((categoryWithBudget) {
                          final category =
                              categoryWithBudget['category'] as Category;
                          final budget = categoryWithBudget['budget']
                              as Map<String, dynamic>;

                          return _buildCategoryWithBudget(category, budget);
                        }).toList(),
                        const SizedBox(height: 16),
                        // Display categories without budgets
                        ...categoriesWithoutBudgets.map((category) {
                          return _buildCategoryWithoutBudget(category);
                        }).toList(),
                      ],
                    ),
            ),
          ),
        ],
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

  Widget _buildCategoryWithBudget(
      Category category, Map<String, dynamic> budget) {
    // Initialize the NumberFormat instance
    final currencyFormat = NumberFormat("#,##0.00", "en_US");

    return FutureBuilder<double>(
      future: _calculateTotalSpent(category.label),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            leading: Icon(category.icon, color: category.color),
            title: Text(category.label),
            trailing: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            leading: Icon(category.icon, color: category.color),
            title: Text(category.label),
            trailing: const Text('Error'),
          );
        } else {
          final totalSpent = snapshot.data ?? 0.0;
          final remainingBudget = budget['limit'] - totalSpent;
          final remainingText = remainingBudget >= 0
              ? 'Remaining: UGX ${currencyFormat.format(remainingBudget)}'
              : 'Over Budget: UGX ${currencyFormat.format(remainingBudget.abs())}';
          final remainingColor =
              remainingBudget >= 0 ? Colors.green : Colors.red;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            child: ListTile(
              leading: Icon(category.icon, color: category.color),
              title: Text(category.label),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Limit: UGX ${currencyFormat.format(budget['limit'])}'),
                  Text('Spent: UGX ${currencyFormat.format(totalSpent)}'),
                  Text(
                    remainingText,
                    style: TextStyle(color: remainingColor),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showBudgetDialog(category.label,
                        currentBudget: budget['limit']);
                  } else if (value == 'remove') {
                    _deleteBudget(category.label);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit Budget'),
                  ),
                  PopupMenuItem<String>(
                    value: 'remove',
                    child: Text('Remove Budget'),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ),
          );
        }
      },
    );
  }

// Helper method to build category without budget
  Widget _buildCategoryWithoutBudget(Category category) {
    return FutureBuilder<double>(
      future: _calculateTotalSpent(category.label),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            leading: Icon(category.icon, color: category.color),
            title: Text(category.label),
            trailing: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            leading: Icon(category.icon, color: category.color),
            title: Text(category.label),
            trailing: const Text('Error'),
          );
        } else {
          final totalSpent = snapshot.data ?? 0.0;
          return ListTile(
            leading: Icon(category.icon, color: category.color),
            title: Text(category.label),
            subtitle: Text('Spent: UGX ${totalSpent.toStringAsFixed(2)}'),
            trailing: ElevatedButton(
              onPressed: () => _showBudgetDialog(category.label),
              child: const Text('Set Budget'),
            ),
          );
        }
      },
    );
  }
}
