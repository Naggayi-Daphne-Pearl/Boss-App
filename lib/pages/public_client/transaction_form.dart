import 'package:boss_app/components/custom_header.dart';
import 'package:boss_app/pages/public_client/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:boss_app/components/custom_header_white.dart';
import 'package:boss_app/components/bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionForm extends StatefulWidget {
  final String? initialTransactionType;
  final String? initialAccount;
  final String? initialCategory;
  final String? initialAmount;
  final DateTime? initialDate;
  final String? initialNotes;

  const TransactionForm({
    super.key,
    this.initialTransactionType,
    this.initialAccount,
    this.initialCategory,
    this.initialAmount,
    this.initialDate,
    this.initialNotes,
  });

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  // Constants for transaction types
  static const List<String> transactionTypes = [
    'Income',
    'Expense',
    'Transfer'
  ];

  // State variables
  String _selectedTransactionType = transactionTypes[0];
  String? _selectedAccount;
  String? _expenseCategory;
  String? _incomeCategory;
  String? _fromAccount;
  String? _toAccount;
  String _notes = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _amount = '0';

  // Calculator state variables
  String _displayText = '0';
  double _firstNum = 0;
  double _secondNum = 0;
  String _operation = '';

  List<String> accountOptions = [];
  List<String> expenseCategories = [];
  List<String> incomeCategories = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  Map<String, String> accountIdMap = {};

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch accounts and categories on initialization

    // Initialize state variables with passed transaction data
    if (widget.initialTransactionType != null &&
        transactionTypes.contains(widget.initialTransactionType)) {
      _selectedTransactionType = widget.initialTransactionType!;
    } else {
      _selectedTransactionType = transactionTypes[0]; // Default to first item
    }
    if (widget.initialAccount != null &&
        accountOptions.contains(widget.initialAccount)) {
      _selectedAccount = widget.initialAccount!;
    }
    if (widget.initialCategory != null) {
      if (_selectedTransactionType == 'Expense' &&
          expenseCategories.contains(widget.initialCategory)) {
        _expenseCategory = widget.initialCategory;
      } else if (_selectedTransactionType == 'Income' &&
          incomeCategories.contains(widget.initialCategory)) {
        _incomeCategory = widget.initialCategory;
      }
    }
    if (widget.initialAmount != null) {
      _amount = widget.initialAmount!;
      _displayText = widget.initialAmount!;
    }
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    if (widget.initialNotes != null) {
      _notes = widget.initialNotes!;
    }
  }

  Future<void> _fetchData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Fetch account options
        final accountDocs = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('accounts')
            .get();

        // Create a map to store account names and their corresponding IDs
        accountIdMap.clear(); // Clear the map before populating it

        setState(() {
          accountOptions = accountDocs.docs.map((doc) {
            String accountName = doc['name'] as String;
            String accountId = doc.id; // Get the document ID (account ID)
            accountIdMap[accountName] = accountId; // Map account name to ID
            return accountName;
          }).toList();
        });

        final categoryDocs = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('categories')
            .get();

        // Filter categories based on whether they are income or expense
        List<String> fetchedExpenseCategories = [];
        List<String> fetchedIncomeCategories = [];

        for (var doc in categoryDocs.docs) {
          if (doc['isIncome']) {
            fetchedIncomeCategories.add(doc['label'] as String);
          } else {
            fetchedExpenseCategories.add(doc['label'] as String);
          }
        }

        setState(() {
          expenseCategories = fetchedExpenseCategories;
          incomeCategories = fetchedIncomeCategories;
          isLoading = false;
        });
      } catch (e) {
        print("Error fetching accounts: $e");
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 12.0), // Horizontal padding for all fields
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHeaderWhite(
                title: 'Add Expenses or Income',
                onLeadingIconPressed: () {
                  // Handle leading icon press
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ToggleButtons(
                    isSelected: transactionTypes
                        .map((type) => type == _selectedTransactionType)
                        .toList(),
                    onPressed: (int index) {
                      setState(() {
                        _selectedTransactionType = transactionTypes[index];
                      });
                    },
                    children: transactionTypes
                        .map(
                          (type) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 8),
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    color: Colors.blue.shade900,
                    selectedColor: Colors.white,
                    fillColor: Colors.blue.shade900,
                    borderColor: Colors.blue.shade900,
                    selectedBorderColor: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedTransactionType == 'Expense' ||
                  _selectedTransactionType == 'Income')
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: _buildDropdown(
                          label: 'Account To',
                          value: _selectedAccount,
                          items: accountOptions,
                          onChanged: (value) => setState(() {
                            _selectedAccount = value;
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: _buildDropdown(
                          label: _selectedTransactionType == 'Expense'
                              ? 'Expense Category'
                              : 'Category',
                          value: _selectedTransactionType == 'Expense'
                              ? _expenseCategory
                              : _incomeCategory,
                          items: _selectedTransactionType == 'Expense'
                              ? expenseCategories
                              : incomeCategories,
                          onChanged: (value) => setState(() {
                            if (_selectedTransactionType == 'Expense') {
                              _expenseCategory = value;
                            } else {
                              _incomeCategory = value;
                            }
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_selectedTransactionType == 'Transfer')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: _buildDropdown(
                              label: 'Account From',
                              value: _fromAccount,
                              items: accountOptions,
                              onChanged: (value) => setState(() {
                                _fromAccount = value;
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: _buildDropdown(
                              label: 'Account To',
                              value: _toAccount,
                              items: accountOptions,
                              onChanged: (value) => setState(() {
                                _toAccount = value;
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Add Notes',
                    labelStyle: TextStyle(
                        color:
                            Colors.blue.shade900), // Optional: Style the label
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Set border radius
                      borderSide: BorderSide(
                        color: Colors.blue.shade900, // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Same radius as border
                      borderSide: BorderSide(
                        color:
                            Colors.blue.shade900, // Border color when enabled
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0), // Same radius
                      borderSide: BorderSide(
                        color:
                            Colors.blue.shade900, // Border color when focused
                        width: 2.0, // Slightly thicker for focus effect
                      ),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) => setState(() {
                    _notes = value;
                  }),
                ),
              ),
              const SizedBox(height: 16),
              _buildAmountInput(),
              const SizedBox(height: 20),
              _buildDateTimePicker(),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _handleTransactionSubmission,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade900,
                  side: BorderSide(color: Colors.blue.shade900),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                ),
                child: const Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Colors.blue.shade900,
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              border: InputBorder.none,
              hintText: 'Select an option',
              hintStyle: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () => _selectDate(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.blue.shade900),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          ),
          child: Text(DateFormat.yMMMd().format(_selectedDate)),
        ),
        ElevatedButton(
          onPressed: () => _selectTime(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              foregroundColor: Colors.white),
          child: Text(_selectedTime.format(context)),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity, // Ensures the border spans 100% width
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade900, width: 1),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display operator
                Text(
                  _operation.isNotEmpty ? _operation : '',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                // Display operand
                Expanded(
                  child: Text(
                    _displayText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                // Backspace button
                IconButton(
                  icon: const Icon(Icons.backspace),
                  color: Colors.blue.shade900,
                  onPressed: () {
                    setState(() {
                      if (_displayText.length > 1) {
                        _displayText =
                            _displayText.substring(0, _displayText.length - 1);
                      } else {
                        _displayText = '0'; // Reset to '0' if empty
                      }
                      _amount = _displayText; // Sync _amount with user input
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildCalculator(),
      ],
    );
  }

  Widget _buildCalculator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _calculatorButtons(
            ['7', '8', '9', '/'],
            isOperator: false,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _calculatorButtons(
            ['4', '5', '6', 'X'],
            isOperator: false,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _calculatorButtons(
            ['1', '2', '3', '-'],
            isOperator: false,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _calculatorButtons(
            ['0', 'C', '=', '+'],
            isOperator: true,
          ),
        ),
      ],
    );
  }

  List<Widget> _calculatorButtons(List<String> labels,
      {bool isOperator = false}) {
    return labels
        .map(
          (label) => GestureDetector(
            onTap: () {
              _onCalculatorButtonClick(label);
            },
            child: Container(
              height: 70,
              width: 70,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isOperator ? Colors.blue.shade900 : Colors.white,
                border: Border.all(color: Colors.blue.shade900, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(2, 3), // Shadow position
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isOperator ? Colors.white : Colors.blue.shade900,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  void _onCalculatorButtonClick(String value) {
    setState(() {
      if (value == 'C') {
        // Clear the calculator
        _displayText = '0';
        _firstNum = 0;
        _secondNum = 0;
        _operation = '';
      } else if (value == '=') {
        // Perform calculation logic
        // Update _amount based on the result
        if (_operation.isNotEmpty) {
          _secondNum = double.tryParse(_displayText) ?? 0;
          switch (_operation) {
            case '+':
              _displayText = (_firstNum + _secondNum).toString();
              break;
            case '-':
              _displayText = (_firstNum - _secondNum).toString();
              break;
            case 'X':
              _displayText = (_firstNum * _secondNum).toString();
              break;
            case '/':
              _displayText = _secondNum != 0
                  ? (_firstNum / _secondNum).toString()
                  : 'Error';
              break;
          }
          _amount = _displayText; // Sync _amount with calculated value
          _operation = '';
        }
      } else if ('0123456789.'.contains(value)) {
        // Append numbers or decimal to _displayText
        if (_displayText == '0') {
          _displayText = value;
        } else {
          _displayText += value;
        }
        _amount = _displayText; // Sync _amount with user input
      } else {
        // Handle operators
        _firstNum = double.tryParse(_displayText) ?? 0;
        _operation = value;
        _displayText = '0';
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleTransactionSubmission() async {
    final user = _auth.currentUser;

    if (user == null) {
      print("User not logged in");
      return;
    }

    if (_amount.isEmpty ||
        double.tryParse(_amount) == null ||
        double.parse(_amount) <= 0) {
      print("Please enter a valid amount");
      return;
    }

    final transactionAmount = double.parse(_amount);

    try {
      // Handle income
      if (_selectedTransactionType == 'Income') {
        String? accountId = accountIdMap[_selectedAccount];
        if (accountId != null) {
          final accountDocRef = _firestore
              .collection('users')
              .doc(user.uid)
              .collection('accounts')
              .doc(accountId);

          final accountSnapshot = await accountDocRef.get();
          if (accountSnapshot.exists) {
            final currentBalance = accountSnapshot['balance'] as double;
            final updatedBalance = currentBalance + transactionAmount;

            // Update the balance in Firestore
            await accountDocRef.update({'balance': updatedBalance});
            _showSnackBar(
                "Income added successfully. New balance: $updatedBalance");
          } else {
            _showSnackBar("Account does not exist.");
          }
        } else {
          _showSnackBar("Account ID not found for the selected account.");
        }
      }
      // Handle expense
      else if (_selectedTransactionType == 'Expense') {
        String? accountId = accountIdMap[_selectedAccount];
        if (accountId != null) {
          final accountDocRef = _firestore
              .collection('users')
              .doc(user.uid)
              .collection('accounts')
              .doc(accountId);

          final accountSnapshot = await accountDocRef.get();
          if (accountSnapshot.exists) {
            final currentBalance = accountSnapshot['balance'] as double;

            // Check if there are sufficient funds for the expense
            if (currentBalance >= transactionAmount) {
              final updatedBalance = currentBalance - transactionAmount;

              // Update the balance in Firestore
              await accountDocRef.update({'balance': updatedBalance});
              print(
                  "Expense subtracted successfully. New balance: $updatedBalance");
            } else {
              // Flag insufficient funds
              _showInsufficientFundsAlert(); // New method to alert the user
              print("Insufficient funds in the account for this expense.");
            }
          } else {
            print("Account does not exist.");
          }
        } else {
          print("Account ID not found for the selected account.");
        }
      }
      // Handle transfer
      else if (_selectedTransactionType == 'Transfer') {
        String? fromAccountId = accountIdMap[_fromAccount];
        String? toAccountId = accountIdMap[_toAccount];

        if (fromAccountId != null && toAccountId != null) {
          final fromAccountDocRef = _firestore
              .collection('users')
              .doc(user.uid)
              .collection('accounts')
              .doc(fromAccountId);

          final toAccountDocRef = _firestore
              .collection('users')
              .doc(user.uid)
              .collection('accounts')
              .doc(toAccountId);

          // Fetch current balances
          final fromAccountSnapshot = await fromAccountDocRef.get();
          final toAccountSnapshot = await toAccountDocRef.get();

          if (fromAccountSnapshot.exists && toAccountSnapshot.exists) {
            final fromCurrentBalance = fromAccountSnapshot['balance'] as double;
            final toCurrentBalance = toAccountSnapshot['balance'] as double;

            // Check if there are sufficient funds for the transfer
            if (fromCurrentBalance >= transactionAmount) {
              final updatedFromBalance = fromCurrentBalance - transactionAmount;
              final updatedToBalance = toCurrentBalance + transactionAmount;

              // Update both accounts in Firestore
              await fromAccountDocRef.update({'balance': updatedFromBalance});
              await toAccountDocRef.update({'balance': updatedToBalance});

              print(
                  "Transfer successful. New balances: From: $updatedFromBalance, To: $updatedToBalance");
            } else {
              print("Insufficient funds in the 'From' account.");
            }
          } else {
            print("One of the accounts does not exist.");
          }
        } else {
          print("Account IDs not found for the selected accounts.");
        }
      }

      // Log the transaction in Firestore (optional)
      final transactionData = {
        'type': _selectedTransactionType,
        'amount': transactionAmount,
        'notes': _notes,
        'date': _selectedDate,
        'time': _selectedTime.format(context),
        'category': _selectedTransactionType == 'Income'
            ? _incomeCategory
            : _expenseCategory,
        'account': _selectedAccount,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .add(transactionData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainMenu()),
      );
    } catch (e) {
      _showSnackBar("Error processing transaction: Try Again Later");
    }
  }

// Helper function to update account balance

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _showInsufficientFundsAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insufficient Funds'),
          content:
              const Text('You do not have enough funds to make this expense.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
