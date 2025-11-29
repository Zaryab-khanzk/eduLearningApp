import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/user_flashcard_progress.dart';

class UserFlashcardProgressDBLayer with ChangeNotifier {
  final String _boxName = 'userProgressBox';
  late Box _box;
  List<UserFlashcardProgress> _progress = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(UserFlashcardProgress progress) {
    _box.put(progress.progressId, progress.toJson());
    _progress.add(progress);
    notifyListeners();
  }

  void deleteFromListOnly(String id) {
    _progress.removeWhere((e) => e.progressId == id);
    notifyListeners();
  }

  void deleteFromHive(String id) {
    _box.delete(id);
    _progress.removeWhere((e) => e.progressId == id);
    notifyListeners();
  }

  void updateFromHive(UserFlashcardProgress progress) {
    _box.put(progress.progressId, progress.toJson());
    final index = _progress.indexWhere((item) => item.progressId == progress.progressId);
    if (index != -1) {
      _progress[index] = progress;
    }
    notifyListeners();
  }

  void clearAll() {
    _progress.clear();
    _box.clear();
    notifyListeners();
  }

  void getAllData() {
    _progress = _box.values
        .map((e) => UserFlashcardProgress.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
  }

  UserFlashcardProgress? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _box.get(id);
    if (data != null) {
      return UserFlashcardProgress.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<UserFlashcardProgress> get progress => _progress;
}