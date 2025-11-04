import 'package:flutter/material.dart';

class NavProvider with ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void setIndex(int i) {
    if (_index == i) return;
    _index = i;
    notifyListeners();
  }

  // Optional: Add method to reset to home
  void resetToHome() {
    setIndex(0);
  }
}
