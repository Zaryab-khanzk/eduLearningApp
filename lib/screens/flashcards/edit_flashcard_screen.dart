// lib/screens/flashcards/edit_flashcard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/flashcards_dbLayer.dart';
import '../../basic_classes/flashcards.dart';

class EditFlashcardScreen extends StatefulWidget {
  final Flashcard flashcard;

  const EditFlashcardScreen({
    super.key,
    required this.flashcard,
  });

  @override
  _EditFlashcardScreenState createState() => _EditFlashcardScreenState();
}

class _EditFlashcardScreenState extends State<EditFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate the form fields with the existing card's data
    _questionController = TextEditingController(text: widget.flashcard.question);
    _answerController = TextEditingController(text: widget.flashcard.answer);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _updateCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final cardDB = Provider.of<FlashcardDBLayer>(context, listen: false);

    // Create a new Flashcard object with the updated details but the same IDs
    final updatedCard = Flashcard(
      cardId: widget.flashcard.cardId, // Keep the same ID
      setId: widget.flashcard.setId,   // Keep the same parent set ID
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      difficulty: widget.flashcard.difficulty, // Keep the same difficulty
      lastReviewed: widget.flashcard.lastReviewed, // Keep the same review date
    );

    // Call the existing updateFromHive method
    cardDB.updateFromHive(updatedCard);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Card'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a question' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter an answer' : null,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _updateCard,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Save Changes'),
                  ),
          ],
        ),
      ),
    );
  }
}