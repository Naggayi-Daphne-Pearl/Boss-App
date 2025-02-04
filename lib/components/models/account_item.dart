import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final double initialAmount;
  final double balance;
  final String currency;
  final VoidCallback onEditDelete;

  const AccountItem({
    Key? key,
    required this.icon,
    required this.name,
    required this.initialAmount,
    required this.currency,
    required this.balance,
    required this.onEditDelete,
  }) : super(key: key);

  String formatAmount(double amount) {
    final format = NumberFormat(
        '#,##0.00', 'en_US'); // Adjust to your currency style if needed
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Set the elevation to 4 for shadow effect
      margin: const EdgeInsets.symmetric(
          vertical: 8.0), // Margin for spacing between cards
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(8.0), // Rounded corners for the card
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal:
                16.0), // Vertical and horizontal padding inside the card
        child: Row(
          children: [
            Icon(icon, size: 40), // Icon on the left
            const SizedBox(width: 16), // Space between icon and text
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to the start
                children: [
                  Text(name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)), // Account name
                  const SizedBox(height: 4), // Space between name and amounts
                  Text(
                      'Initial Amount: $currency ${formatAmount(initialAmount)}'),
                  // Initial amount
                  Text(
                      'Balance: $currency ${formatAmount(balance)}'), // Balance
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert), // Three-dotted icon
              onPressed: onEditDelete,
            ),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit Name'),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete Account'),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        // Handle edit action
      } else if (value == 'delete') {
        // Handle delete action
      }
    });
  }
}
