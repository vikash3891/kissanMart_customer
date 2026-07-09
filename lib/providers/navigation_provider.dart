import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedTab = 0;

  int get selectedTab => _selectedTab;

  void setTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  void reset() {
    _selectedTab = 0;
    notifyListeners();
  }
}
