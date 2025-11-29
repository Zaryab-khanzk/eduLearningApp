// lib/screens/profile/test_history_screen.dart

// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/test_session_dbLayer.dart';
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/flashcard_set_dbLayer.dart';
import '../../basic_classes/test_session.dart';
import '../flashcards/test_results_screen.dart';

class TestHistoryScreen extends StatelessWidget {
  const TestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDB = Provider.of<UserDBLayer>(context, listen: false);
    final setDB = Provider.of<FlashcardSetDBLayer>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Test History'),
      ),
      body: Consumer<TestSessionDBLayer>(
        builder: (context, sessionDB, child) {
          final mySessions = sessionDB.sessions
              .where((s) => s.userId == userDB.currentUser?.userId)
              .toList();
          
          // Sort by most recent first
          mySessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

          if (mySessions.isEmpty) {
            return const Center(
              child: Text('You have not completed any tests yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: mySessions.length,
            itemBuilder: (context, index) {
              final session = mySessions[index];
              final setName = setDB.getDataById(session.setId)?.title ?? 'Unknown Set';
              final date = session.completedAt.toLocal().toString().substring(0, 10);

              return Card(
                child: ListTile(
                  title: Text(setName),
                  subtitle: Text('Completed on: $date'),
                  trailing: Text('${session.correctAnswers}/${session.totalQuestions}', style: Theme.of(context).textTheme.headlineSmall),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TestResultsScreen(session: session),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}