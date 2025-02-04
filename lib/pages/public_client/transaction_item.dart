import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int amount;
  final DateTime date;
  final String type;
  final String notes;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.notes,
    required this.onEdit,
    required this.onDelete,
  });

  String formatDate(DateTime date) {
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  String formatAmount(int amount) {
    return NumberFormat('#,##0').format(amount);
  }

  // Truncate notes to the first 8 characters
  String truncateNotes(String notes) {
    return notes.length > 20 ? '${notes.substring(0, 20)}...' : notes;
  }

  @override
  Widget build(BuildContext context) {
    // Set color based on transaction type
    Color amountColor = type == 'Expense' ? Colors.red : Colors.green;

    // Prepend minus sign for Expense transactions
    String formattedAmount = type == 'Expense'
        ? '-${formatAmount(amount)}' // Format amount with commas for Expense
        : formatAmount(amount); // Format amount with commas for Income

    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade900),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatDate(date)), // Display date
          Text(truncateNotes(notes),
              style: TextStyle(color: Colors.grey)), // Show truncated notes
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formattedAmount,
            style: TextStyle(
                color: amountColor, // Use color based on type
                fontWeight: FontWeight.bold),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit(); // Call the edit callback
              } else if (value == 'delete') {
                onDelete(); // Call the delete callback
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
