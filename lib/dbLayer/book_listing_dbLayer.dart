import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/book_listing.dart';

class BookListingDBLayer with ChangeNotifier {
  final String _boxName = 'bookListingsBox';
  late Box _box;
  List<BookListing> _listings = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(BookListing listing) {
    _box.put(listing.bookId, listing.toJson());
    _listings.add(listing);
    notifyListeners();
  }

  void deleteFromListOnly(String id) {
    _listings.removeWhere((e) => e.bookId == id);
    notifyListeners();
  }

  void deleteFromHive(String id) {
    _box.delete(id);
    _listings.removeWhere((e) => e.bookId == id);
    notifyListeners();
  }

  void updateFromHive(BookListing listing) {
    _box.put(listing.bookId, listing.toJson());
    final index = _listings.indexWhere((item) => item.bookId == listing.bookId);
    if (index != -1) {
      _listings[index] = listing;
    }
    notifyListeners();
  }

  void clearAll() {
    _listings.clear();
    _box.clear();
    notifyListeners();
  }

  void getAllData() {
    _listings = _box.values
        .map((e) => BookListing.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
  }

  BookListing? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _box.get(id);
    if (data != null) {
      return BookListing.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<BookListing> get listings => _listings;
}