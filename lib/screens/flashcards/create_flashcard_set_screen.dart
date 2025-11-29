// lib/screens/flashcards/create_flashcard_set_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import necessary DB layers and models
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/flashcard_set_dbLayer.dart';
import '../../basic_classes/flashcard_set.dart';

class CreateFlashcardSetScreen extends StatefulWidget {
  const CreateFlashcardSetScreen({super.key});

  @override
  _CreateFlashcardSetScreenState createState() => _CreateFlashcardSetScreenState();
}

class _CreateFlashcardSetScreenState extends State<CreateFlashcardSetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- BACKEND CONNECTION ---
  Future<void> _createSet() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing
    }

    setState(() {
      _isLoading = true;
    });

    // Access the providers with `listen: false` for a one-time action
    final userDB = Provider.of<UserDBLayer>(context, listen: false);
    final setDB = Provider.of<FlashcardSetDBLayer>(context, listen: false);

    final currentUser = userDB.currentUser;
    if (currentUser == null) {
      // Safeguard in case the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not identify current user.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Create the new FlashcardSet object
    final newSet = FlashcardSet(
      setId: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdBy: currentUser.userId, // Link the set to the current user
      createdAt: DateTime.now(),
    );

    // Add the new set to the database
    setDB.addToHive(newSet);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Set "${newSet.title}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Pop the screen to return to the list of flashcard sets
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Flashcard Set'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Give your new set a title and description.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Chapter 5 Vocabulary',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a title for your set' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Key terms from the computer networking lecture.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _createSet,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Create Set'),
                  ),
          ],
        ),
      ),
    );
  }
}