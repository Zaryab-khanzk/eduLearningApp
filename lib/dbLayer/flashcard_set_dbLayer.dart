import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../basic_classes/flashcard_set.dart';
// ignore: unused_import
import '../basic_classes/flashcards.dart'; // Import the Flashcard model

class FlashcardSetDBLayer with ChangeNotifier {
  final String _boxName = 'flashcardSetsBox';
  late Box _box;
  List<FlashcardSet> _sets = [];

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    getAllData();
  }

  void addToHive(FlashcardSet set) {
    _box.put(set.setId, set.toJson());
    _sets.add(set);
    notifyListeners();
  }

  void deleteFromListOnly(String id) {
    _sets.removeWhere((e) => e.setId == id);
    notifyListeners();
  }

  // --- NEW METHOD ---
  // Deletes a set AND all flashcards associated with it.
  Future<void> deleteSetAndCards(String setId) async {
    // 1. Open the flashcards box to perform deletions.
    // Ensure 'flashcardsBox' is the correct name from FlashcardDBLayer.
    final flashcardsBox = await Hive.openBox('flashcardsBox');

    // 2. Find all card IDs that belong to the set being deleted.
    final List<dynamic> cardKeysToDelete = flashcardsBox.keys.where((key) {
      final cardMap = flashcardsBox.get(key) as Map?;
      return cardMap != null && cardMap['set_id'] == setId;
    }).toList();
    
    // 3. Delete each of those cards from the flashcardsBox.
    await flashcardsBox.deleteAll(cardKeysToDelete);

    // 4. Finally, delete the set itself from the setsBox.
    await _box.delete(setId);

    // 5. Update the local in-memory list and notify the UI.
    _sets.removeWhere((set) => set.setId == setId);
    notifyListeners();
    print('Deleted set $setId and ${cardKeysToDelete.length} associated cards.');
  }

  void updateFromHive(FlashcardSet set) {
    _box.put(set.setId, set.toJson());
    final index = _sets.indexWhere((item) => item.setId == set.setId);
    if (index != -1) {
      _sets[index] = set;
    }
    notifyListeners();
  }

  void clearAll() {
    _sets.clear();
    _box.clear();
    notifyListeners();
  }

  void getAllData() {
    _sets = _box.values
        .map((e) => FlashcardSet.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
  }

  FlashcardSet? getDataById(String id) {
    final Map<dynamic, dynamic>? data = _box.get(id);
    if (data != null) {
      return FlashcardSet.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<FlashcardSet> get sets => _sets;
}