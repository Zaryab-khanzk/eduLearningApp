// lib/screens/flashcards/test_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // For shuffling

import '../../dbLayer/flashcards_dbLayer.dart';
import '../../dbLayer/test_session_dbLayer.dart';
import '../../dbLayer/users_dbLayer.dart';
import '../../basic_classes/flashcards.dart';
import '../../basic_classes/test_session.dart';
import 'test_results_screen.dart';

class TestScreen extends StatefulWidget {
  final String setId;
  final String setName;

  const TestScreen({
    super.key,
    required this.setId,
    required this.setName,
  });

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late List<Flashcard> _shuffledCards;
  int _currentIndex = 0;
  int _correctAnswers = 0;
  final List<String> _incorrectCardIds = [];
  bool _isAnswerVisible = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndShuffleCards();
  }

  void _loadAndShuffleCards() {
    // Use a post-frame callback to safely access the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cardDB = Provider.of<FlashcardDBLayer>(context, listen: false);
      final cards = cardDB.cards.where((c) => c.setId == widget.setId).toList();
      cards.shuffle(Random()); // Shuffle the cards for the test
      setState(() {
        _shuffledCards = cards;
        _isLoading = false;
      });
    });
  }

  void _markAnswer(bool wasCorrect) {
    if (wasCorrect) {
      _correctAnswers++;
    } else {
      _incorrectCardIds.add(_shuffledCards[_currentIndex].cardId);
    }

    if (_currentIndex + 1 >= _shuffledCards.length) {
      _finishTest();
    } else {
      setState(() {
        _currentIndex++;
        _isAnswerVisible = false;
      });
    }
  }

  void _finishTest() {
    final userDB = Provider.of<UserDBLayer>(context, listen: false);
    final sessionDB = Provider.of<TestSessionDBLayer>(context, listen: false);
    
    final newSession = TestSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userDB.currentUser!.userId,
      setId: widget.setId,
      completedAt: DateTime.now(),
      totalQuestions: _shuffledCards.length,
      correctAnswers: _correctAnswers,
      incorrectCardIds: _incorrectCardIds,
    );
    
    sessionDB.addToHive(newSession);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TestResultsScreen(session: newSession),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }

    final currentCard = _shuffledCards[_currentIndex];
    final progress = (_currentIndex + 1) / _shuffledCards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Test: ${widget.setName}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Question ${_currentIndex + 1} of ${_shuffledCards.length}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 4,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _isAnswerVisible ? currentCard.answer : currentCard.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_isAnswerVisible)
              ElevatedButton(
                onPressed: () => setState(() => _isAnswerVisible = true),
                child: const Text('Show Answer'),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _markAnswer(false),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Incorrect'),
                  ),
                  ElevatedButton(
                    onPressed: () => _markAnswer(true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Correct'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}