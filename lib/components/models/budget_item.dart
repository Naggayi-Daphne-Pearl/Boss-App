import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetItem extends StatelessWidget {
  final String category;
  final double limit;
  final double spent;
  final Function(String, double) onEdit; // Add a callback for editing

  const BudgetItem({
    super.key,
    required this.category,
    required this.limit,
    required this.spent,
    required this.onEdit, // Accept the callback
  });

  @override
  Widget build(BuildContext context) {
    final double remaining = limit - spent;
    final Color remainingColor = remaining >= 0 ? Colors.green : Colors.red;

    final NumberFormat currencyFormat = NumberFormat('#,##0.00');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                _showEditBudgetDialog(context);
              },
              child: const Text('Edit'),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Limit: UGX ${currencyFormat.format(limit)}'),
            Text('Spent: UGX ${currencyFormat.format(spent)}'),
            Text(
              'Remaining: UGX ${currencyFormat.format(remaining)}',
              style: TextStyle(color: remainingColor),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context) {
    double? newLimit;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Budget for $category'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'New Budget Limit'),
            keyboardType: TextInputType.number,
            onChanged: (value) => newLimit = double.tryParse(value),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newLimit != null) {
                  onEdit(category, newLimit!); // Call the edit callback
                  Navigator.of(context).pop();
                } else {
                  // Show a snackbar or some feedback for invalid input
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid limit.')),
                  );
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
  }
}
