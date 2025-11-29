// lib/screens/flashcards/test_results_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/flashcard_set_dbLayer.dart';
import '../../dbLayer/flashcards_dbLayer.dart';
import '../../basic_classes/test_session.dart';

class TestResultsScreen extends StatelessWidget {
  final TestSession session;

  const TestResultsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final setDB = Provider.of<FlashcardSetDBLayer>(context, listen: false);
    final cardDB = Provider.of<FlashcardDBLayer>(context, listen: false);
    
    final setName = setDB.getDataById(session.setId)?.title ?? 'Unknown Set';
    final score = session.correctAnswers;
    final total = session.totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Results for "$setName"', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('You scored: $score / $total', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(height: 24),
            if (session.incorrectCardIds.isNotEmpty) ...[
              const Text('Review your mistakes:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: session.incorrectCardIds.length,
                  itemBuilder: (context, index) {
                    final card = cardDB.getDataById(session.incorrectCardIds[index]);
                    return Card(
                      child: ListTile(
                        title: Text('Q: ${card?.question ?? "N/A"}'),
                        subtitle: Text('A: ${card?.answer ?? "N/A"}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}