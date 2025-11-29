import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/flashcard_set_dbLayer.dart';
import '../../basic_classes/flashcard_set.dart';

class EditFlashcardSetScreen extends StatefulWidget {
  final FlashcardSet flashcardSet;

  const EditFlashcardSetScreen({
    super.key,
    required this.flashcardSet,
  });

  @override
  _EditFlashcardSetScreenState createState() => _EditFlashcardSetScreenState();
}

class _EditFlashcardSetScreenState extends State<EditFlashcardSetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate the form fields with the existing set's data
    _titleController = TextEditingController(text: widget.flashcardSet.title);
    _descriptionController = TextEditingController(text: widget.flashcardSet.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateSet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final setDB = Provider.of<FlashcardSetDBLayer>(context, listen: false);

    // Create a new FlashcardSet object with the updated details but the same IDs
    final updatedSet = FlashcardSet(
      setId: widget.flashcardSet.setId, // Keep the same ID
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdBy: widget.flashcardSet.createdBy, // Keep the same creator
      createdAt: widget.flashcardSet.createdAt, // Keep the same creation date
    );

    // Call the updateFromHive method
    setDB.updateFromHive(updatedSet);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Set "${updatedSet.title}" updated successfully!'),
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
        title: Text('Edit "${widget.flashcardSet.title}"'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _updateSet,
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