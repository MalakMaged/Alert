import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Authentication Providers
final authProvider = Provider<Auth>((ref) => Auth());

class Auth {
  bool isAuthenticated = false;

  void login(String email, String password) {
    // Perform login logic
    isAuthenticated = true;
  }

  void logout() {
    // Perform logout logic
    isAuthenticated = false;
  }
}

// User Profile Provider
final userProfileProvider = ChangeNotifierProvider<UserProfile>((ref) {
  return UserProfile();
});

class UserProfile extends ChangeNotifier {
  String username = "John Doe";

  void updateProfile(String newUsername) {
    username = newUsername;
    notifyListeners();
  }
}

// Counter Provider (for demonstration)
final counterProvider = Provider<int>((ref) {
  return 0;
});

class Counter {
  int value = 0;

  void increment() {
    value++;
  }
}
