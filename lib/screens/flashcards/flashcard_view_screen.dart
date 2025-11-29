// lib/screens/flashcards/flashcard_view_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/flashcard_set_dbLayer.dart';
import '../../dbLayer/flashcards_dbLayer.dart';
import '../../dbLayer/users_dbLayer.dart';
import '../../basic_classes/flashcards.dart';
// ignore: unused_import
import '../../basic_classes/flashcard_set.dart';
import 'test_screen.dart';
import 'add_flashcard_screen.dart';
import 'edit_flashcard_screen.dart'; // <<<--- IMPORT THE NEW EDIT SCREEN

class FlashcardViewScreen extends StatefulWidget {
  final String setId;

  const FlashcardViewScreen({super.key, required this.setId});

  @override
  State<FlashcardViewScreen> createState() => _FlashcardViewScreenState();
}

class _FlashcardViewScreenState extends State<FlashcardViewScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setDB = Provider.of<FlashcardSetDBLayer>(context, listen: false);
    final userDB = Provider.of<UserDBLayer>(context, listen: false);
    
    final flashcardSet = setDB.getDataById(widget.setId);
    
    if (flashcardSet == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) Navigator.of(context).pop();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final bool isOwner = flashcardSet.createdBy == userDB.currentUser?.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(flashcardSet.title),
        actions: [
           Consumer<FlashcardDBLayer>(
            builder: (context, cardDB, child) {
              final bool hasCards = cardDB.cards.any((c) => c.setId == widget.setId);
              // Only show the test button if there are cards in the set
              return Visibility(
                visible: hasCards,
                child: IconButton(
                  icon: const Icon(Icons.quiz),
                  tooltip: 'Take a Test',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TestScreen(
                          setId: flashcardSet.setId,
                          setName: flashcardSet.title,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Consumer<FlashcardDBLayer>(
            builder: (context, cardDB, child) {
              final cardsInSet = cardDB.cards.where((c) => c.setId == widget.setId).toList();
              
              // Show buttons only if the user is the owner AND there are cards in the set
              if (!isOwner || cardsInSet.isEmpty) {
                return const SizedBox.shrink(); // Return an empty widget if not owner or no cards
              }
              
              final currentCard = cardsInSet[_currentPage];

              return Row(
                children: [
                  // --- EDIT CARD BUTTON ---
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Current Card',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditFlashcardScreen(flashcard: currentCard),
                        ),
                      );
                    },
                  ),
                  // --- DELETE CARD BUTTON ---
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete Current Card',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Delete Card'),
                          content: const Text('Are you sure you want to permanently delete this card?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.of(dialogContext).pop(),
                            ),
                            TextButton(
                              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                cardDB.deleteFromHive(currentCard.cardId);
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          )
        ],
      ),
      body: Consumer<FlashcardDBLayer>(
        builder: (context, cardDB, child) {
          final cardsInSet = cardDB.cards
              .where((card) => card.setId == widget.setId)
              .toList();

          if (cardsInSet.isEmpty) {
            return const Center(
              child: Text(
                'This set has no cards yet. Tap + to add one!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          if (_currentPage >= cardsInSet.length) {
            _currentPage = cardsInSet.isNotEmpty ? cardsInSet.length - 1 : 0;
          }

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: cardsInSet.length,
                  itemBuilder: (context, index) {
                    return _FlashcardWidget(flashcard: cardsInSet[index]);
                  },
                ),
              ),
              if (cardsInSet.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Card ${_currentPage + 1} of ${cardsInSet.length}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Visibility(
        visible: isOwner,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddFlashcardScreen(setId: widget.setId),
            ));
          },
          tooltip: 'Add New Card',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// --- The _FlashcardWidget helper remains unchanged ---
class _FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  const _FlashcardWidget({required this.flashcard});
  @override
  __FlashcardWidgetState createState() => __FlashcardWidgetState();
}
class __FlashcardWidgetState extends State<_FlashcardWidget> {
  bool _isFlipped = false;
  void _flipCard() {
    setState(() { _isFlipped = !_isFlipped; });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isFlipped
                    ? Text(widget.flashcard.answer, key: const ValueKey('answer'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 22))
                    : Text(widget.flashcard.question, key: const ValueKey('question'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}