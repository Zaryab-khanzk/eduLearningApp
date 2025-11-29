// lib/db_layers/users_dbLayer.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../basic_classes/users.dart'; // Ensure this path is correct

class UserDBLayer with ChangeNotifier {
  final String _boxName = 'usersBox';
  late Box _userBox;
  List<Users> _users = [];

  // --- NEW: Add a variable to track the currently logged-in user ---
  Users? _currentUser;

  // --- NEW: Public getter for the current user ---
  Users? get currentUser => _currentUser;

  Future<void> init() async {
    _userBox = await Hive.openBox(_boxName);
    getAllData();
    await _loadCurrentUser(); // Load the saved user session
  }

  // Load the current user from SharedPreferences
  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('currentUserId');
    if (savedUserId != null) {
      _currentUser = getDataById(savedUserId);
      if (_currentUser != null) {
        notifyListeners();
        debugPrint(
          '✅ Loaded current user: ${_currentUser!.name} (${_currentUser!.role})',
        );
      }
    }
  }

  // Save the current user ID to SharedPreferences
  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString('currentUserId', _currentUser!.userId);
      debugPrint(
        '💾 Saved current user: ${_currentUser!.name} (${_currentUser!.role})',
      );
    } else {
      await prefs.remove('currentUserId');
      debugPrint('🗑️ Cleared current user from preferences');
    }
  }

  void signUp(Users user) {
    _userBox.put(user.userId, user.toJson());
    _users.add(user);
    debugPrint('📝 User signed up: ${user.name} (Role: "${user.role}")');
    notifyListeners();
  }

  // --- MODIFIED: The login method now sets the current user ---
  Future<Users?> login(String email, String password) async {
    try {
      final user = _users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      // If login is successful, set the currentUser state
      _currentUser = user;
      await _saveCurrentUser(); // Persist the login session
      notifyListeners(); // Notify listeners that the user state has changed
      debugPrint('✅ User logged in: ${user.name} (${user.role})');
      return user;
    } catch (e) {
      _currentUser = null; // Ensure current user is null on failed login
      debugPrint('❌ Login failed for email: $email');
      return null;
    }
  }

  // --- NEW: The new, SAFE logout method ---
  // This is the method you should call from your logout button.
  Future<void> logOut() async {
    _currentUser = null; // Simply clear the current session
    await _saveCurrentUser(); // Clear from persistent storage
    notifyListeners(); // Notify UI to update (e.g., navigate to login screen)
    debugPrint('👋 User logged out');
  }

  // --- RENAMED: The old `logOut` method is now correctly named ---
  // This method is DESTRUCTIVE and should be used with extreme caution,
  // for example, in a developer debug menu.
  void deleteAllUsers() {
    _users.clear();
    _userBox.clear();
    _currentUser = null; // Also clear the session
    notifyListeners();
  }

  // (The rest of the file remains the same)

  void deleteFromHive(String id) {
    _userBox.delete(id);
    _users.removeWhere((e) => e.userId == id);
    if (_currentUser?.userId == id) {
      _currentUser = null;
    }
    notifyListeners();
  }

  void updateFromHive(Users user) {
    _userBox.put(user.userId, user.toJson());
    final index = _users.indexWhere((item) => item.userId == user.userId);
    if (index != -1) {
      _users[index] = user;
    }
    if (_currentUser?.userId == user.userId) {
      _currentUser = user;
    }
    notifyListeners();
  }

  void getAllData() {
    _users = _userBox.values
        .map((e) => Users.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    // Do not notify listeners here on initial load,
    // as it can cause issues during app startup.
  }

  List<Users> get users => _users;

  Users? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _userBox.get(id);
    if (data != null) {
      return Users.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<Users> get teachers {
    return _users.where((user) => user.role == 'Teacher').toList();
  }

  List<Users> get students {
    return _users.where((user) => user.role == 'Student').toList();
  }

  bool isEmailRegistered(String email) {
    return _users.any(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );
  }
}
