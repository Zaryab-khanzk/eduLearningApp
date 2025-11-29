import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/group_members.dart';

class GroupMemberDBLayer with ChangeNotifier {
  final String _boxName = 'groupMembersBox';
  late Box _box;
  List<GroupMember> _members = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(GroupMember member) {
    _box.put(member.memberId, member.toJson());
    _members.add(member);
    notifyListeners();
  }

  void deleteFromListOnly(String id) {
    _members.removeWhere((e) => e.memberId == id);
    notifyListeners();
  }

  void deleteFromHive(String id) {
    _box.delete(id);
    _members.removeWhere((e) => e.memberId == id);
    notifyListeners();
  }

  void updateFromHive(GroupMember member) {
    _box.put(member.memberId, member.toJson());
    final index = _members.indexWhere((item) => item.memberId == member.memberId);
    if (index != -1) {
      _members[index] = member;
    }
    notifyListeners();
  }

  void clearAll() {
    _members.clear();
    _box.clear();
    notifyListeners();
  }

  void getAllData() {
    _members = _box.values
        .map((e) => GroupMember.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
  }

  GroupMember? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _box.get(id);
    if (data != null) {
      return GroupMember.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<GroupMember> get members => _members;
}