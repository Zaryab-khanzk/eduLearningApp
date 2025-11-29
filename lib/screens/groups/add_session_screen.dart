// lib/screens/groups/add_session_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import necessary DB layer and model
import '../../dbLayer/study_sessions_dbLayer.dart';
import '../../basic_classes/study_sessions.dart';

class AddSessionScreen extends StatefulWidget {
  final String groupId;

  const AddSessionScreen({super.key, required this.groupId});

  @override
  _AddSessionScreenState createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();

  // State variable to hold the selected date and time
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- UI HELPER: Function to show the date and time picker ---
  Future<void> _pickDateTime() async {
    // Show Date Picker first
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ), // Sessions can be scheduled up to a year in advance
    );

    if (pickedDate == null) return; // User canceled the date picker

    // Show Time Picker next
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (pickedTime == null) return; // User canceled the time picker

    // Combine the picked date and time and update the state
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // --- BACKEND CONNECTION ---
  Future<void> _scheduleSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a date and time for the session.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final sessionDB = Provider.of<StudySessionDBLayer>(context, listen: false);

    // Create the new StudySession object
    final newSession = StudySession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: widget.groupId,
      topic: _topicController.text.trim(),
      scheduledTime: _selectedDateTime!,
      notes: _notesController.text.trim(),
    );

    // Add it to the database
    sessionDB.addToHive(newSession);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session scheduled successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to the GroupDetailScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule New Session')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Session Topic',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.topic),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter a topic'
                  : null,
            ),
            const SizedBox(height: 16),

            // --- Date and Time Picker UI ---
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDateTime == null
                            ? 'Tap to select date and time'
                            : _selectedDateTime!.toLocal().toString().substring(
                                0,
                                16,
                              ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _selectedDateTime == null
                              ? Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(0.6)
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'e.g., chapters to cover, things to bring...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _scheduleSession,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Schedule Session'),
                  ),
          ],
        ),
      ),
    );
  }
}
