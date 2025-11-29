// lib/db_layers/shared_content_dbLayer.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/shared_content.dart';

class SharedContentDBLayer with ChangeNotifier {
  final String _boxName = 'sharedContentBox';
  late Box _box;
  List<SharedContent> _sharedItems = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(SharedContent item) {
    _box.put(item.sharedContentId, item.toJson());
    _sharedItems.add(item);
    notifyListeners();
  }

  void getAllData() {
    _sharedItems = _box.values
        .map((e) => SharedContent.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    // No notifyListeners() on initial load
  }

  List<SharedContent> get sharedItems => _sharedItems;
}