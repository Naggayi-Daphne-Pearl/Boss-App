import 'package:boss_app/pages/public_client/confirm_public.dart';
import 'package:flutter/material.dart';

class ChooseType extends StatefulWidget {
  @override
  _ChooseTypePageState createState() => _ChooseTypePageState();
}

class _ChooseTypePageState extends State<ChooseType> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());

  void _onChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 3) {
        FocusScope.of(context).nextFocus(); // Move to next field
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus(); // Move to previous field if empty
    }
  }

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
                  'Private or Public',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Choose to be public or private with your finances',
                  style: TextStyle(
                    fontSize: 14,
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
                      'Please select and option.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        // if (_formKey.currentState!.validate()) {
                        //   pint('Phone: ${_phoneController.text}');
                        //   print('Password: ${_passwordController.text}');
                        // }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConfirmPublic(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      child: Text(
                        'Public',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    // Sign Up Button
                    OutlinedButton(
                      onPressed: () {
                        // Navigator.pushNamed(context, '/signup');
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
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      child: Text(
                        "Private",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),

                    // Sign In Button

                    SizedBox(height: 30),

                    // Informational Text with Warning Icon
                    Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 8), // Space between the icon and text
                        Expanded(
                          // Take up the remaining space
                          child: Text(
                            'If public you can rank yourself with other users.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
