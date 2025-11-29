// lib/dbLayer/announcement_dbLayer.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/announcement.dart';

class AnnouncementDBLayer with ChangeNotifier {
  final String _boxName = 'announcementsBox';
  late Box _box;
  List<Announcement> _announcements = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(Announcement announcement) {
    _box.put(announcement.announcementId, announcement.toJson());
    // Add to the beginning of the list to show newest first
    _announcements.insert(0, announcement);
    notifyListeners();
  }
  
  void deleteFromHive(String announcementId) {
    _box.delete(announcementId);
    _announcements.removeWhere((a) => a.announcementId == announcementId);
    notifyListeners();
  }

  void getAllData() {
    _announcements = _box.values
        .map((e) => Announcement.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    // Sort by most recent first upon initial load
    _announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    // No notifyListeners on initial load
  }

  List<Announcement> get announcements => _announcements;
}