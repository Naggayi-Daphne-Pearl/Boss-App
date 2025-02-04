import 'package:flutter/material.dart';
import 'package:boss_app/pages/public_client/confirm_public.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicy> {
  final _formKey = GlobalKey<FormState>();
  bool _isDocumentationRead = false; // Variable to track the radio button

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Boss App Privacy Policy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
            BoxShadow(
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
                SizedBox(height: 30),
                Text(
                  'BOSS: Personal Finance in a Box (“we,” “us,” or “our”) is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our application (“App”) and services. By using the App, you agree to the practices outlined in this Privacy Policy.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 25),
                Text(
                  '1. Information We Collect',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'a. Personal Information\n'
                  'We collect minimal personal information to ensure anonymity and usability of the App. This includes:\n'
                  '• Your assigned username (e.g., Boss Opio)\n'
                  '• Optional information you provide, such as email for account recovery or support requests.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 15),
                Text(
                  'b. Financial Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'The App collects financial information that you voluntarily input, including:\n'
                  '• Expense details (amount, category, location, date, purpose)\n'
                  '• Linked bank or mobile money account data (optional)\n'
                  '• Project-related expenses (e.g., group trips, construction projects).',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 25),
                Text(
                  '3. Privacy and Data Use',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Privacy Policy for BOSS: Personal Finance in a Box\n'
                  'Effective Date: [Insert Date]\n\n'
                  'BOSS: Personal Finance in a Box (“we,” “us,” or “our”) is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our application (“App”) and services. By using the App, you agree to the practices outlined in this Privacy Policy.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 15),
                Text(
                  '4. Your Privacy Choices',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '• Anonymous Usage: By default, the App assigns anonymous usernames, ensuring that your identity remains private.\n'
                  '• Data Control: You may delete or update your financial records directly within the App.\n'
                  '• Account Deletion: You can request account deletion by contacting us at support@bossapp.com.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 15),
                Text(
                  '5. Limitations of Use',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '2. How We Use Your Information\n'
                  'We use the information collected to:\n'
                  '• Provide core App features like expense tracking, rankings, and project management.\n'
                  '• Improve user experience and optimize the App’s functionality.\n'
                  '• Generate anonymized consumer insights for internal and external research purposes.\n'
                  '• Develop new features and personalized recommendations.\n'
                  '• Enhance security and prevent unauthorized access.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 15),
                Text(
                  '6. Data Sharing and Disclosure',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'We do not sell or share your personal data with third parties for marketing purposes. However, we may share anonymized and aggregated data with:\n'
                  '• Business Partners: For market research or collaborative projects that align with the App’s goals.\n'
                  '• Service Providers: To assist with App operations (e.g., analytics, payment processing) under strict data confidentiality agreements.\n'
                  '• Legal Authorities: If required to comply with legal obligations or enforce our terms.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 15),
                Text(
                  '7. Data Security',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'We implement industry-standard security measures to protect your data, including:\n'
                  '• Encryption: All data transmissions are encrypted using secure protocols (e.g., HTTPS).\n'
                  '• Access Controls: User data is accessible only to authorized personnel.\n'
                  '• Regular Audits: We perform routine security audits to identify and address vulnerabilities.\n'
                  'While we strive to protect your data, no system is entirely foolproof. We encourage users to practice secure behaviors, such as safeguarding account credentials.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 15),
                Text(
                  '8. Liability',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Retention of Data\n'
                  'We retain user data for as long as necessary to provide services and comply with legal obligations. Anonymized data may be retained indefinitely for analytical purposes.\n'
                  'Children’s Privacy\n'
                  'The App is designed for users aged 18 and above. We do not knowingly collect personal data from children under 18. If we become aware of such collection, we will take immediate steps to delete the data.\n'
                  'Third-Party Links and Services\n'
                  'The App may contain links to third-party services (e.g., crowdfunding, payment gateways). We are not responsible for the privacy practices of these services. Users are encouraged to review their respective privacy policies.\n'
                  'Changes to This Privacy Policy\n'
                  'We may update this Privacy Policy to reflect changes in the App or applicable laws. Users will be notified of significant updates, and the “Effective Date” will be revised accordingly. Continued use of the App constitutes acceptance of the updated policy.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 15),
                Text(
                  '9. Governing Law',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'These Terms are governed by the laws of Uganda. Any disputes arising under these Terms shall be resolved in the courts of Uganda',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                SizedBox(height: 25),
                SizedBox(height: 20),
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
                ElevatedButton(
                  onPressed: () {
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
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  ),
                  child: Text('Accept'),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
