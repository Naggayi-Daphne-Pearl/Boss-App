import 'package:boss_app/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:boss_app/pages/public_client/confirm_public.dart';

class TermsAndConditions extends StatefulWidget {
  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditions> {
  final _formKey = GlobalKey<FormState>();
  bool _isDocumentationRead = false; // Variable to track the radio button

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(0.0),
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Welcome to BOSS: Personal Finance in a Box ("App"), a personal finance platform designed to help users track expenses, manage finances, and gain valuable insights. By accessing or using the App, you agree to be bound by the following terms and conditions ("Terms"). If you do not agree, please do not use the App.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  '1. Definitions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  '"App" refers to the BOSS application and its associated services.\n'
                  '"User" refers to anyone accessing or using the App.\n'
                  '"We," Us," or "Our" refers to the BOSS team and its affiliates.\n'
                  '"Content" includes all data, text, graphics, and other material provided through the App.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                const Text(
                  '2. User Responsibilities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  '• Users must provide accurate and truthful information when registering and using the App.\n'
                  '• Users are responsible for safeguarding their account credentials and for all activities under their account.\n'
                  '• Users agree not to use the App for illegal or unauthorized purposes.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 25),
                const Text(
                  '3. Privacy and Data Use',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'We prioritize user anonymity by assigning random usernames (e.g., Boss Opio).\n'
                  'User data, including financial entries, will be used to provide App services and generate insights.\n'
                  'Data shared in the App will remain confidential and used in accordance with our [Privacy Policy].',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                const Text(
                  '4. Features and Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Expense Tracking: Users can record daily expenses, categorize them, and link accounts for holistic management.\n'
                  'Crowdfunding and Payments: Users can create projects (e.g., trips, construction) and share expenses or contribute to crowdfunding campaigns.\n'
                  'Rankings and Insights: The App may display user activity rankings and generate insights based on usage patterns.\n'
                  'Future features may include investment tools, payment gateways (e.g., QR code payments), and forums for financial discussions.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                const Text(
                  '5. Limitations of Use',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Users must not reverse-engineer, copy, or exploit the App or its features for commercial purposes without prior permission.\n'
                  'We reserve the right to suspend accounts that violate these Terms.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                const Text(
                  '6. Intellectual Property',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'All trademarks, logos, and App content are owned by BOSS or its licensors. Unauthorized use is prohibited.\n'
                  'Users retain ownership of data they input into the App but grant us a license to use anonymized data for insights and research purposes.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                const Text(
                  '7. Disclaimer of Warranties',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'The App is provided "as is" without any warranties, express or implied.\n'
                  'We do not guarantee that the App will be free from errors, interruptions, or security vulnerabilities.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                const Text(
                  '8. Liability',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'To the fullest extent permitted by law, BOSS will not be liable for any direct, indirect, incidental, or consequential damages arising from the use of the App.\n'
                  'Users acknowledge that financial decisions made using the App are their sole responsibility.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                const Text(
                  '9. Amendments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'These Terms may be updated periodically to reflect changes in our services or applicable laws.\n'
                  'Continued use of the App after updates constitutes acceptance of the revised Terms.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                const Text(
                  '10. Governing Law',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'These Terms are governed by the laws of Uganda. Any disputes arising under these Terms shall be resolved in the courts of Uganda',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 25),
                const SizedBox(height: 20),
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
                    const Text('I read the documentation'),
                  ],
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _isDocumentationRead
                      ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 16),
                  ),
                  child: const Text('Accept'),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
