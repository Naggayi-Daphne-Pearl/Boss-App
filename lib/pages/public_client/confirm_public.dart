import 'package:boss_app/pages/auth/privacy_policy.dart';
import 'package:boss_app/pages/auth/terms_and_conditions.dart';
import 'package:flutter/material.dart';

class ConfirmPublic extends StatefulWidget {
  @override
  _ConfirmPublicPageState createState() => _ConfirmPublicPageState();
}

class _ConfirmPublicPageState extends State<ConfirmPublic> {
  final _formKey = GlobalKey<FormState>();
  bool _isDocumentationRead = false; // Variable to track the radio button

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Top half gradient background
          Container(
            height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Bottom half background color (white or dark mode variant)
          Positioned(
            top: MediaQuery.of(context).size.height / 2,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            ),
          ),

          Positioned(
            top: 60,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Going Public',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Centered form container
          Center(
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              width: 320,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      'By going public you agree to share your financial net worth with other users using boss.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      'READ CAREFULLY',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 25),

                    // Outlined Buttons for Terms and Conditions and Privacy Policy
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => TermsAndConditions(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? Colors.grey.shade800 : Colors.white,
                        foregroundColor: Colors.blueAccent,
                        side: BorderSide(color: Colors.blueAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      ),
                      child: Text('Terms and Conditions'),
                    ),
                    SizedBox(height: 10), // Space between buttons
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => PrivacyPolicy(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? Colors.grey.shade800 : Colors.white,
                        foregroundColor: Colors.blueAccent,
                        side: BorderSide(color: Colors.blueAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      ),
                      child: Text('Privacy Policy'),
                    ),
                    SizedBox(height: 20), // Space before radio button

                    // Radio Button for reading the documentation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio(
                          value: true,
                          groupValue: _isDocumentationRead,
                          onChanged: (value) {
                            setState(() {
                              _isDocumentationRead = value!;
                            });
                          },
                        ),
                        Text('I read the documentation'),
                      ],
                    ),

                    SizedBox(height: 25),

                    // Accept Button
                    ElevatedButton(
                      onPressed: () {
                        // Handle accept action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      ),
                      child: Text('Accept'),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
