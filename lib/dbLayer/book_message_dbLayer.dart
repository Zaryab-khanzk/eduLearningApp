import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/book_message.dart';

class BookMessageDBLayer with ChangeNotifier {
  final String _boxName = 'bookMessagesBox';
  late Box _box;
  List<BookMessage> _messages = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(BookMessage message) {
    _box.put(message.messageId, message.toJson());
    _messages.add(message);
    notifyListeners();
  }

  void deleteFromListOnly(String id) {
    _messages.removeWhere((e) => e.messageId == id);
    notifyListeners();
  }

  void deleteFromHive(String id) {
    _box.delete(id);
    _messages.removeWhere((e) => e.messageId == id);
    notifyListeners();
  }

  void updateFromHive(BookMessage message) {
    _box.put(message.messageId, message.toJson());
    final index = _messages.indexWhere((item) => item.messageId == message.messageId);
    if (index != -1) {
      _messages[index] = message;
    }
    notifyListeners();
  }

  void clearAll() {
    _messages.clear();
    _box.clear();
    notifyListeners();
  }

  void getAllData() {
    _messages = _box.values
        .map((e) => BookMessage.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
  }

  BookMessage? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _box.get(id);
    if (data != null) {
      return BookMessage.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<BookMessage> get messages => _messages;
}