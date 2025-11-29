// lib/screens/flashcards/add_flashcard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import necessary DB layer and model
import '../../dbLayer/flashcards_dbLayer.dart';
import '../../basic_classes/flashcards.dart';

class AddFlashcardScreen extends StatefulWidget {
  final String setId;

  const AddFlashcardScreen({
    super.key,
    required this.setId,
  });

  @override
  _AddFlashcardScreenState createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  // --- BACKEND CONNECTION ---
  Future<void> _addCard() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing.
    }

    setState(() {
      _isLoading = true;
    });

    // Access the provider with `listen: false` for a one-time action
    final cardDB = Provider.of<FlashcardDBLayer>(context, listen: false);

    // Create the new Flashcard object
    final newCard = Flashcard(
      cardId: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
      setId: widget.setId, // Link this card to the parent set
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      difficulty: 1, // Default difficulty, can be changed later
      lastReviewed: DateTime.now(), // Default review date
    );

    // Add the new card to the database
    cardDB.addToHive(newCard);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New card added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Pop the screen to return to the flashcard viewer
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a New Card'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- UI Component: Question Field ---
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'e.g., What is the capital of Japan?',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a question' : null,
            ),
            const SizedBox(height: 24),

            // --- UI Component: Answer Field ---
            TextFormField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                hintText: 'e.g., Tokyo',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter an answer' : null,
            ),
            const SizedBox(height: 32),

            // --- UI Component: Submit Button ---
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _addCard,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Add Card to Set'),
                  ),
          ],
        ),
      ),
    );
  }
}