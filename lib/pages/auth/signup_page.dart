import 'package:boss_app/pages/auth/choose_type.dart';
import 'package:boss_app/pages/auth/login_page.dart';
import 'package:boss_app/pages/auth/verification_page.dart';
import 'package:boss_app/pages/public_client/confirm_public.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new state variable to manage password visibility
  bool _isPasswordVisible = false; // Initialize to false

  @override
  void dispose() {
    // Dispose controllers to free resources
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to handle user sign-up
  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      // Check if password and confirm password match
      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        Fluttertoast.showToast(
            msg: "Passwords do not match!", backgroundColor: Colors.red);
        return;
      }
      try {
        // Create user with email and password
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Update user's display name with the provided username
        await userCredential.user
            ?.updateDisplayName(_usernameController.text.trim());

        Fluttertoast.showToast(
            msg: "Sign-Up Successful!", backgroundColor: Colors.green);

        // Navigate to the login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConfirmPublic()),
        );
      } catch (e) {
        // Display error message
        Fluttertoast.showToast(
            msg: "Error: ${e.toString()}", backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Gradient background
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

            // Bottom container for form
            Positioned(
              top: MediaQuery.of(context).size.height / 2,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              ),
            ),

            // Header text
            Positioned(
              top: 60,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create An Account',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Sign-up form
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 150),
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [
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
                      const SizedBox(height: 20),

                      // Username field
                      buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        isDarkMode: isDarkMode,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your username'
                            : null,
                        margin: const EdgeInsets.only(bottom: 20),
                      ),

                      const SizedBox(height: 15),

                      // Email field
                      buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        isDarkMode: isDarkMode,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your email address'
                            : null,
                        margin: const EdgeInsets.only(bottom: 20),
                      ),

                      const SizedBox(height: 15),

                      // Password field
                      buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        isDarkMode: isDarkMode,
                        obscureText: _isPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your password'
                            : null,
                        margin: const EdgeInsets.only(bottom: 20),
                      ),

                      const SizedBox(height: 15),

                      // Confirm Password field
                      buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        isDarkMode: isDarkMode,
                        obscureText: _isPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please confirm your password'
                            : null,
                        margin: const EdgeInsets.only(bottom: 20),
                      ),

                      const SizedBox(height: 30),

                      // Sign-Up button
                      ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
                        ),
                        child: const Text('Sign Up'),
                      ),

                      const SizedBox(height: 20),

                      // Redirect to login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text('Log In'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isDarkMode,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required String? Function(String?) validator,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: Colors.blue, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: Colors.blue, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: Colors.blue, width: 1),
              ),
              suffixIcon: onToggleVisibility != null
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.blue,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
