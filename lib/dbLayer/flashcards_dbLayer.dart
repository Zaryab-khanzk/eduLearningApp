import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/flashcards.dart';

class FlashcardDBLayer with ChangeNotifier {
  final String _boxName = 'flashcardsBox';
  late Box _box;
  List<Flashcard> _cards = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(Flashcard card) {
    _box.put(card.cardId, card.toJson());
    _cards.add(card);
    notifyListeners();
  }

  void deleteFromListOnly(String id) {
    _cards.removeWhere((e) => e.cardId == id);
    notifyListeners();
  }

  void deleteFromHive(String id) {
    _box.delete(id);
    _cards.removeWhere((e) => e.cardId == id);
    notifyListeners();
  }

  void updateFromHive(Flashcard card) {
    _box.put(card.cardId, card.toJson());
    final index = _cards.indexWhere((item) => item.cardId == card.cardId);
    if (index != -1) {
      _cards[index] = card;
    }
    notifyListeners();
  }

  void clearAll() {
    _cards.clear();
    _box.clear();
    notifyListeners();
  }

  void getAllData() {
    _cards = _box.values
        .map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
  }

  Flashcard? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _box.get(id);
    if (data != null) {
      return Flashcard.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<Flashcard> get cards => _cards;
}