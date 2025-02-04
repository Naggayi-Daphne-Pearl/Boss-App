import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String _user = '';

  String get user => _user;

  void setUser(String username) {
    _user = username;
    notifyListeners();
  }

  void clearUsername() {
    _user = '';
    notifyListeners();
  }
}
