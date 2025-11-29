// lib/dbLayer/course_material_dbLayer.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/course_material.dart';

class CourseMaterialDBLayer with ChangeNotifier {
  final String _boxName = 'courseMaterialsBox';
  late Box _box;
  List<CourseMaterial> _materials = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(CourseMaterial material) {
    _box.put(material.materialId, material.toJson());
    _materials.add(material);
    notifyListeners();
  }
  
  void deleteFromHive(String materialId) {
    _box.delete(materialId);
    _materials.removeWhere((m) => m.materialId == materialId);
    notifyListeners();
  }

  void getAllData() {
    _materials = _box.values
        .map((e) => CourseMaterial.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    // No notifyListeners on initial load
  }

  List<CourseMaterial> get materials => _materials;
}