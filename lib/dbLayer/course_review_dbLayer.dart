import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/course_review.dart';

class CourseReviewDBLayer with ChangeNotifier {
  final String _boxName = 'courseReviewsBox';
  late Box _box;
  List<CourseReview> _reviews = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(CourseReview review) {
    _box.put(review.reviewId, review.toJson());
    _reviews.add(review);
    notifyListeners();
  }

  void deleteFromListOnly(String id) {
    _reviews.removeWhere((e) => e.reviewId == id);
    notifyListeners();
  }

  void deleteFromHive(String id) {
    _box.delete(id);
    _reviews.removeWhere((e) => e.reviewId == id);
    notifyListeners();
  }

  void updateFromHive(CourseReview review) {
    _box.put(review.reviewId, review.toJson());
    final index = _reviews.indexWhere((item) => item.reviewId == review.reviewId);
    if (index != -1) {
      _reviews[index] = review;
    }
    notifyListeners();
  }

  void clearAll() {
    _reviews.clear();
    _box.clear();
    notifyListeners();
  }

  void getAllData() {
    _reviews = _box.values
        .map((e) => CourseReview.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
  }

  CourseReview? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _box.get(id);
    if (data != null) {
      return CourseReview.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<CourseReview> get reviews => _reviews;
}