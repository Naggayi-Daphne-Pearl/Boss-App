import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomHeaderWhite extends StatelessWidget {
  final String title;
  final VoidCallback onLeadingIconPressed;

  const CustomHeaderWhite({
    Key? key,
    required this.title,
    required this.onLeadingIconPressed,
  }) : super(key: key);
  String _capitalizeTitle(String title) {
    return title
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Adjust height as needed
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center content vertically
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Image.asset(
                    "assets/logo/boss_colored.png",
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                  onPressed: onLeadingIconPressed,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _capitalizeTitle(title), // Capitalize the first letters
                      style: TextStyle(
                        color: Colors.blue.shade900, // Font color
                        fontSize: 20, // Font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.blue.shade900),
                  onSelected: (value) {
                    _handleMenuSelection(context, value);
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue.shade900),
                            SizedBox(width: 8),
                            Text('Add Expense'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'income',
                        child: Row(
                          children: [
                            Icon(Icons.question_mark,
                                color: Colors.blue.shade900),
                            SizedBox(width: 8),
                            Text('Add Income'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'friends',
                        child: Row(
                          children: [
                            Icon(Icons.people, color: Colors.blue.shade900),
                            SizedBox(width: 8),
                            Text('Add Friends'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings, color: Colors.blue.shade900),
                            SizedBox(width: 8),
                            Text('Settings'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.blue.shade900),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to handle the selected menu item
  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'expense':
        // Navigate to profile page
        Navigator.pushNamed(context, '/expenses');
        break;
      case 'income':
        // Navigate to profile page
        Navigator.pushNamed(context, '/expenses');
        break;
      case 'friends':
        // Navigate to profile page
        // Navigator.pushNamed(context, '/profile');
        break;
      case 'settings':
        // Navigate to settings page
        // Navigator.pushNamed(context, '/settings');
        break;
      case 'logout':
        _showLogoutConfirmation(context);
        break;
    }
  }

  // Function to show a confirmation dialog for logout
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                // Clear session data
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Navigate to login screen
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }
}
