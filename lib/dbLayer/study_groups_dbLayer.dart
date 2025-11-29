import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/study_groups.dart';

class StudyGroupDBLayer with ChangeNotifier {
  final String _boxName = 'studyGroupsBox';
  late Box _box;
  List<StudyGroup> _groups = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(StudyGroup group) {
    _box.put(group.groupId, group.toJson());
    _groups.add(group);
    notifyListeners();
  }

  void deleteFromListOnly(String id) {
    _groups.removeWhere((e) => e.groupId == id);
    notifyListeners();
  }

  void deleteFromHive(String id) {
    _box.delete(id);
    _groups.removeWhere((e) => e.groupId == id);
    notifyListeners();
  }

  void updateFromHive(StudyGroup group) {
    _box.put(group.groupId, group.toJson());
    final index = _groups.indexWhere((item) => item.groupId == group.groupId);
    if (index != -1) {
      _groups[index] = group;
    }
    notifyListeners();
  }

  void clearAll() {
    _groups.clear();
    _box.clear();
    notifyListeners();
  }

  void getAllData() {
    _groups = _box.values
        .map((e) => StudyGroup.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
  }

  StudyGroup? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _box.get(id);
    if (data != null) {
      return StudyGroup.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<StudyGroup> get groups => _groups;
}