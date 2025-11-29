// lib/dbLayer/course_enrollment_dbLayer.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/course_enrollment.dart';

class CourseEnrollmentDBLayer with ChangeNotifier {
  final String _boxName = 'courseEnrollmentsBox';
  late Box _box;
  List<CourseEnrollment> _enrollments = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(CourseEnrollment enrollment) {
    _box.put(enrollment.enrollmentId, enrollment.toJson());
    _enrollments.add(enrollment);
    notifyListeners();
  }

  void getAllData() {
    _enrollments = _box.values
        .map((e) => CourseEnrollment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    // No notifyListeners on initial load
  }

  List<CourseEnrollment> get enrollments => _enrollments;
}