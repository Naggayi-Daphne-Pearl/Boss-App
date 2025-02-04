import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:boss_app/components/bottom_nav.dart';
import 'package:boss_app/components/custom_header.dart';
import 'package:boss_app/components/models/category.dart';
import 'package:boss_app/pages/public_client/transaction_screen.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Category> categories = [];
  final List<IconData> availableIcons = [
    Icons.category,
    Icons.shopping_cart,
    Icons.fastfood,
    Icons.home,
    Icons.directions_car,
    Icons.checkroom,
    Icons.restaurant,
    Icons.movie,
    Icons.house,
    Icons.videogame_asset,
    Icons.phone,
    Icons.baby_changing_station,
    Icons.local_florist,
    Icons.school,
    Icons.receipt,
    Icons.fitness_center,
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final categoryDocs = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('categories')
            .get();

        setState(() {
          categories = categoryDocs.docs.map((doc) {
            final data = doc.data();
            return Category(
              id: doc.id,
              // icon: IconData(data['icon'], fontFamily: 'MaterialIcons'),
              icon: availableIcons[data['icon']] ??
                  Icons.category, 
              color: Color(data['color']),
              isIncome: data['isIncome'],
              label: data['label'],
            );
          }).toList();

          if (categories.isEmpty) {
            _addDefaultCategories(user.uid);
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error fetching categories: $e');
      print(e);
    }
  }

  Future<void> _addDefaultCategories(String userId) async {
    final defaultExpenseCategories = [
      Category(
          label: 'Food',
          icon: Icons.fastfood,
          color: Colors.blue,
          isIncome: false,
          id: 'expense_food'),
      Category(
          label: 'Transportation',
          icon: Icons.directions_car,
          color: Colors.blue,
          isIncome: false,
          id: 'expense_transportation'),
      Category(
          label: 'Rent',
          icon: Icons.home,
          color: Colors.blue,
          isIncome: false,
          id: 'expense_rent'),
      Category(
          label: 'Education',
          icon: Icons.school,
          color: Colors.blue,
          isIncome: false,
          id: 'expense_education'),
      Category(
          label: 'Car',
          icon: Icons.directions_car,
          color: Colors.blue,
          isIncome: false,
          id: 'expense_car'),
    ];

    final defaultIncomeCategories = [
      Category(
          label: 'Awards',
          icon: Icons.military_tech,
          color: Colors.green,
          isIncome: true,
          id: 'income_awards'),
      Category(
          label: 'Coupons',
          icon: Icons.card_giftcard,
          color: Colors.green,
          isIncome: true,
          id: 'income_coupons'),
      Category(
          label: 'Salary',
          icon: Icons.attach_money,
          color: Colors.green,
          isIncome: true,
          id: 'income_salary'),
      Category(
          label: 'Sale',
          icon: Icons.sell,
          color: Colors.green,
          isIncome: true,
          id: 'income_sale'),
    ];

    try {
      for (var category in defaultExpenseCategories) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('categories')
            .add(category.toMap());
      }
      for (var category in defaultIncomeCategories) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('categories')
            .add(category.toMap());
      }
    } catch (e) {
      _showSnackBar('Error adding default categories: $e');
    }
  }

  Future<void> _addCategoryToFirestore(
      String label, IconData icon, bool isIncome) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Check for existing category names
        final existingCategory = categories.firstWhere(
          (category) => category.label == label,
          orElse: () => Category(
              id: '',
              label: '',
              icon: Icons.category,
              color: Colors.transparent,
              isIncome: false),
        );

        if (existingCategory.label.isNotEmpty) {
          _showSnackBar('Category name already exists!');
          return; // Exit if the category name already exists
        }

        final newCategory = Category(
          id: UniqueKey().toString(),
          icon: icon,
          label: label,
          color: Colors.blue,
          isIncome: isIncome,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('categories')
            .add(newCategory.toMap());

        setState(() {
          categories.add(newCategory);
        });
      }
    } catch (e) {
      _showSnackBar('Error adding category: $e');
    }
  }

  void _showAddCategoryDialog() {
    String? categoryName;
    IconData selectedIcon = availableIcons.first;
    bool isIncome = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Category Name'),
                      onChanged: (value) => categoryName = value,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Type:'),
                        Row(
                          children: [
                            const Text('Income'),
                            Radio<bool>(
                              value: true,
                              groupValue: isIncome,
                              onChanged: (value) {
                                setState(() {
                                  isIncome = value!;
                                });
                              },
                            ),
                            const Text('Expense'),
                            Radio<bool>(
                              value: false,
                              groupValue: isIncome,
                              onChanged: (value) {
                                setState(() {
                                  isIncome = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.blue.shade900, width: 1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: SizedBox(
                        height: 100,
                        child: GridView.count(
                          crossAxisCount: 3,
                          children: availableIcons.map((icon) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIcon = icon;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: selectedIcon == icon
                                      ? Colors.blue[500]
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: Colors.black),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (categoryName != null && categoryName!.isNotEmpty) {
                      _addCategoryToFirestore(
                          categoryName!, selectedIcon, isIncome);
                      Navigator.of(context).pop();
                    } else {
                      _showSnackBar('Category name cannot be empty!');
                    }
                  },
                  child: const Text('Add'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _editCategoryInFirestore(Category category) async {
    String? categoryName = category.label;
    IconData selectedIcon = availableIcons.contains(category.icon)
        ? category.icon
        : availableIcons.first;
    bool isIncome = category.isIncome;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Category Name'),
                      onChanged: (value) => categoryName = value,
                      controller: TextEditingController(text: category.label),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: SizedBox(
                        height: 100,
                        child: GridView.count(
                          crossAxisCount: 3,
                          children: availableIcons.map((icon) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIcon = icon;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: selectedIcon == icon
                                      ? Colors.blue[100]
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: Colors.black),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Type:'),
                        Row(
                          children: [
                            const Text('Income'),
                            Radio<bool>(
                              value: true,
                              groupValue: isIncome,
                              onChanged: (value) {
                                setState(() {
                                  isIncome = value!;
                                });
                              },
                            ),
                            const Text('Expense'),
                            Radio<bool>(
                              value: false,
                              groupValue: isIncome,
                              onChanged: (value) {
                                setState(() {
                                  isIncome = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (categoryName != null && categoryName!.isNotEmpty) {
                      _updateCategoryInFirestore(
                          category, categoryName!, selectedIcon, isIncome);
                      Navigator.of(context).pop();
                    } else {
                      _showSnackBar('Category name cannot be empty!');
                    }
                  },
                  child: const Text('Update'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateCategoryInFirestore(
      Category category, String label, IconData icon, bool isIncome) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('categories')
            .doc(category.id)
            .update({
          'label': label,
          'icon': icon.codePoint,
          'isIncome': isIncome,
        });

        setState(() {
          category.label = label;
          category.icon = icon;
          category.isIncome = isIncome;
        });
      }
    } catch (e) {
      _showSnackBar('Error updating category: $e');
    }
  }

  Future<void> _deleteCategoryFromFirestore(Category category) async {
    // Show confirmation dialog before deletion
    final bool? shouldDelete = await _showDeleteConfirmationDialog(context);

    if (shouldDelete == true) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('categories')
              .doc(category.id)
              .delete();

          setState(() {
            categories.remove(category);
          });
        }
      } catch (e) {
        _showSnackBar('Error deleting category: $e');
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible:
          false, // Prevent dismissal by tapping outside the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels the deletion
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Separate income and expense categories
    final incomeCategories =
        categories.where((category) => category.isIncome).toList();
    final expenseCategories =
        categories.where((category) => !category.isIncome).toList();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomHeader(
            title: 'Your Categories',
            onLeadingIconPressed: () {},
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: categories.isEmpty
                  ? const Center(child: Text('No categories available'))
                  : ListView(
                      children: [
                        _buildCategorySection(
                            incomeCategories, 'Income Categories', 'Income'),
                        const SizedBox(height: 16),
                        _buildCategorySection(
                            expenseCategories, 'Expense Categories', 'Expense'),
                      ],
                    ),
            ),
          ),
          _buildAddCategoryButton(),
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

  Widget _buildCategorySection(
      List<Category> categories, String title, String subtitle) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const Divider(color: Colors.blue),
        ListView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: category.isIncome ? Colors.blue : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: Colors.white,
                ),
              ),
              title: Text(category.label),
              subtitle: Text(subtitle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionScreen(
                      category: category.label,
                      icon: category.icon,
                    ),
                  ),
                );
              },
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editCategoryInFirestore(category);
                  } else if (value == 'delete') {
                    _deleteCategoryFromFirestore(category);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: const [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddCategoryButton() {
    return Center(
      child: TextButton(
        onPressed: _showAddCategoryDialog,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          textStyle: const TextStyle(fontSize: 16),
          side: const BorderSide(color: Colors.blue, width: 2),
        ),
        child: const Text('ADD CATEGORY'),
      ),
    );
  }
}
