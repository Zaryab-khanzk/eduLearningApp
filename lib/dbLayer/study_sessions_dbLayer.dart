import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/study_sessions.dart';

class StudySessionDBLayer with ChangeNotifier {
  final String _boxName = 'studySessionsBox';
  late Box _box;
  List<StudySession> _sessions = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(StudySession session) {
    _box.put(session.sessionId, session.toJson());
    _sessions.add(session);
    notifyListeners();
  }

  void deleteFromListOnly(String id) {
    _sessions.removeWhere((e) => e.sessionId == id);
    notifyListeners();
  }

  void deleteFromHive(String id) {
    _box.delete(id);
    _sessions.removeWhere((e) => e.sessionId == id);
    notifyListeners();
  }

  void updateFromHive(StudySession session) {
    _box.put(session.sessionId, session.toJson());
    final index = _sessions.indexWhere((item) => item.sessionId == session.sessionId);
    if (index != -1) {
      _sessions[index] = session;
    }
    notifyListeners();
  }

  void clearAll() {
    _sessions.clear();
    _box.clear();
    notifyListeners();
  }

  void getAllData() {
    _sessions = _box.values
        .map((e) => StudySession.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
  }

  StudySession? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _box.get(id);
    if (data != null) {
      return StudySession.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<StudySession> get sessions => _sessions;
}