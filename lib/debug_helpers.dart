// Debug helper functions to diagnose enrollment button issue

import 'package:flutter/material.dart';
import 'dbLayer/users_dbLayer.dart';

void debugPrintAllUsers(UserDBLayer userDB) {
  debugPrint('═══════════════════════════════════════');
  debugPrint('📊 ALL USERS IN DATABASE:');
  debugPrint('═══════════════════════════════════════');

  if (userDB.users.isEmpty) {
    debugPrint('   ⚠️  No users in database');
  } else {
    for (var i = 0; i < userDB.users.length; i++) {
      final user = userDB.users[i];
      debugPrint('   User ${i + 1}:');
      debugPrint('     - ID: ${user.userId}');
      debugPrint('     - Name: ${user.name}');
      debugPrint('     - Email: ${user.email}');
      debugPrint('     - Role: "${user.role}" (length: ${user.role.length})');
      debugPrint('     - Role bytes: ${user.role.codeUnits}');
      debugPrint('     - Lowercase: "${user.role.toLowerCase()}"');
      debugPrint('     - Is "Student"?: ${user.role == "Student"}');
      debugPrint(
        '     - Is "student" (lower)?: ${user.role.toLowerCase() == "student"}',
      );
      debugPrint('   ---');
    }
  }

  debugPrint('═══════════════════════════════════════');
  debugPrint('🔐 CURRENT LOGGED IN USER:');
  debugPrint('═══════════════════════════════════════');
  if (userDB.currentUser == null) {
    debugPrint('   ⚠️  No user logged in');
  } else {
    final current = userDB.currentUser!;
    debugPrint('   - ID: ${current.userId}');
    debugPrint('   - Name: ${current.name}');
    debugPrint('   - Email: ${current.email}');
    debugPrint('   - Role: "${current.role}"');
    debugPrint('   - Role lowercase: "${current.role.toLowerCase()}"');
    debugPrint(
      '   - isStudent check: ${current.role.toLowerCase() == "student"}',
    );
  }
  debugPrint('═══════════════════════════════════════\n');
}
