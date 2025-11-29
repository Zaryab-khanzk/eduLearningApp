// lib/screens/teacher/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection';

import '../../dbLayer/course_material_dbLayer.dart';
import '../../dbLayer/flashcard_set_dbLayer.dart';
import '../../dbLayer/test_session_dbLayer.dart';
import '../../dbLayer/flashcards_dbLayer.dart';
import '../../basic_classes/courses.dart';
import '../../basic_classes/shared_content.dart' show ContentType;

class AnalyticsScreen extends StatelessWidget {
  final Courses course;
  const AnalyticsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics for "${course.courseName}"'),
      ),
      body: Consumer3<CourseMaterialDBLayer, TestSessionDBLayer, FlashcardSetDBLayer>(
        builder: (context, materialDB, sessionDB, setDB, child) {
          
          // 1. Find all official flashcard sets for this course
          final officialSetIds = materialDB.materials
              .where((m) =>
                  m.courseId == course.courseId &&
                  m.contentType == ContentType.flashcardSet)
              .map((m) => m.contentId)
              .toList();

          if (officialSetIds.isEmpty) {
            return const Center(child: Text('No official flashcard sets found for this course.'));
          }
          
          return ListView.builder(
            itemCount: officialSetIds.length,
            itemBuilder: (context, index) {
              final setId = officialSetIds[index];
              final set = setDB.getDataById(setId!);
              if (set == null) return const SizedBox.shrink();

              // 2. Find all test sessions related to this flashcard set
              final relevantSessions = sessionDB.sessions
                  .where((s) => s.setId == setId)
                  .toList();
              
              // 3. Calculate analytics
              int totalCorrect = 0;
              int totalQuestions = 0;
              List<String> allIncorrectIds = [];
              
              for (var session in relevantSessions) {
                totalCorrect += session.correctAnswers;
                totalQuestions += session.totalQuestions;
                allIncorrectIds.addAll(session.incorrectCardIds);
              }
              
              double averageScore = totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0;
              
              String mostDifficultCard = 'N/A';
              if (allIncorrectIds.isNotEmpty) {
                final counts = HashMap<String, int>();
                for (var id in allIncorrectIds) {
                  counts[id] = (counts[id] ?? 0) + 1;
                }
                final sorted = counts.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
                final card = Provider.of<FlashcardDBLayer>(context, listen: false).getDataById(sorted.first.key);
                mostDifficultCard = card?.question ?? 'Card not found';
              }

              return ExpansionTile(
                title: Text(set.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  ListTile(
                    title: const Text('Average Score'),
                    trailing: Text('${averageScore.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  ListTile(
                    title: const Text('Total Attempts'),
                    trailing: Text(relevantSessions.length.toString()),
                  ),
                  ListTile(
                    title: const Text('Most Difficult Card'),
                    subtitle: Text(mostDifficultCard),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}