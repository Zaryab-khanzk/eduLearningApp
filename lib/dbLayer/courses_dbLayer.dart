// lib/dbLayer/courses_dbLayer.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/courses.dart';

class CourseDBLayer with ChangeNotifier {
  final String _boxName = 'coursesBox';
  late Box _box;
  List<Courses> _courses = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(Courses course) {
    _box.put(course.courseId, course.toJson());
    _courses.add(course);
    notifyListeners();
  }

  void deleteFromListOnly(String id) {
    _courses.removeWhere((e) => e.courseId == id);
    notifyListeners();
  }

  void deleteFromHive(String id) {
    _box.delete(id);
    _courses.removeWhere((e) => e.courseId == id);
    notifyListeners();
  }

  // --- NEW METHOD: To delete a course AND its associated reviews ---
  Future<void> deleteCourseAndData(String courseId) async {
    // 1. Open the courseReviewsBox to perform deletions.
    // Ensure 'courseReviewsBox' is the correct name from your CourseReviewDBLayer.
    final reviewsBox = await Hive.openBox('courseReviewsBox');
    
    // 2. Find all keys of reviews that belong to the course being deleted.
    final List<dynamic> reviewKeysToDelete = reviewsBox.keys.where((key) {
      final reviewMap = reviewsBox.get(key) as Map?;
      return reviewMap != null && reviewMap['course_id'] == courseId;
    }).toList();
    
    // 3. Delete all those reviews from the reviewsBox.
    if (reviewKeysToDelete.isNotEmpty) {
      await reviewsBox.deleteAll(reviewKeysToDelete);
    }
    
    // 4. Finally, delete the course itself from the coursesBox.
    await _box.delete(courseId);
    
    // 5. Update the local in-memory list and notify the UI.
    _courses.removeWhere((course) => course.courseId == courseId);
    notifyListeners();
    
    print('Deleted course $courseId and ${reviewKeysToDelete.length} associated reviews.');
  }

  void updateFromHive(Courses course) {
    _box.put(course.courseId, course.toJson());
    final index = _courses.indexWhere((item) => item.courseId == course.courseId);
    if (index != -1) {
      _courses[index] = course;
    }
    notifyListeners();
  }

  void clearAll() {
    _courses.clear();
    _box.clear();
    notifyListeners();
  }

  void getAllData() {
    _courses = _box.values
        .map((e) => Courses.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
  }

  Courses? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _box.get(id);
    if (data != null) {
      return Courses.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<Courses> get courses => _courses;
}