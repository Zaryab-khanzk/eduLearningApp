// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/users_dbLayer.dart';
import '../auth/login_screen.dart';
import 'test_history_screen.dart';
import '../flashcards/flashcard_sets_screen.dart'; // <<<--- IMPORT THIS

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDB = Provider.of<UserDBLayer>(context);
    final currentUser = userDB.currentUser;
    final bool isStudent = currentUser?.role == 'Student';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Profile Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Name: ${currentUser?.name ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${currentUser?.email ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Role: ${currentUser?.role ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),

              // --- NEW: Button for teachers to manage their flashcards ---
              ElevatedButton.icon(
                icon: const Icon(Icons.style_outlined),
                label: const Text('My Flashcard Sets'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FlashcardSetsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Only show "Test History" button to students
              if (isStudent)
                ElevatedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('View My Test History'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TestHistoryScreen(),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await userDB.logOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
