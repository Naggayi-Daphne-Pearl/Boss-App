import 'package:boss_app/pages/public_client/analysis_page.dart';
import 'package:boss_app/pages/public_client/boss_accounts.dart';
import 'package:boss_app/pages/public_client/budget_page.dart';
import 'package:boss_app/pages/public_client/category_page.dart';
import 'package:boss_app/pages/public_client/income_summary.dart';
import 'package:boss_app/pages/public_client/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainMenu(),
          ),
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AnalysisPage(),
          ),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BudgetPage(),
          ),
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AccountsPage(),
          ),
        );
        break;
      case 4:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CategoriesPage(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color iconColor = Colors.white;
    Color backgroundColor = Colors.blue.shade900;

    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Spacer(),
          _buildNavItem(Icons.home, "Home", 0, iconColor),
          const Spacer(),
          _buildNavItem(Icons.pie_chart, "Analysis", 1, iconColor),
          const Spacer(), // More space for the FAB
          // FloatingActionButton(
          //   onPressed: _showMenuOptions,
          //   child: Icon(Icons.add, color: Colors.white),
          //   backgroundColor: Colors.blueAccent,
          //   mini: screenWidth <= 360,
          // ),
          // Spacer(flex: 2), // More space for the FAB
          _buildNavItem(Icons.calculate, "Budgets", 2, iconColor),
          const Spacer(), // More space for the FAB

          _buildNavItem(Icons.wallet, "Accounts", 3, iconColor),
          const Spacer(), // More space for the FAB

          _buildNavItem(Icons.sell, "Categories", 4, iconColor),

          // Spacer(),
          // _buildNavItem(Icons.settings, "Settings", 4, iconColor),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, Color iconColor) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
            child: Icon(
              icon,
              size: isSelected ? 28 : 24,
              color: isSelected
                  ? (index == 3 ? Colors.red : iconColor)
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (index == 3 ? Colors.red : iconColor)
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
