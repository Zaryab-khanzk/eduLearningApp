// lib/db_layers/test_session_dbLayer.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/test_session.dart';

class TestSessionDBLayer with ChangeNotifier {
  final String _boxName = 'testSessionsBox';
  late Box _box;
  List<TestSession> _sessions = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(TestSession session) {
    _box.put(session.sessionId, session.toJson());
    _sessions.add(session);
    notifyListeners();
  }

  void getAllData() {
    _sessions = _box.values
        .map((e) => TestSession.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    // No notifyListeners() on initial load to prevent startup race conditions.
  }

  TestSession? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _box.get(id);
    if (data != null) {
      return TestSession.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
  
  // Getter for the full list of sessions
  List<TestSession> get sessions => _sessions;
}