// lib/screens/courses/add_course_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import necessary DB layers and models
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/courses_dbLayer.dart';
import '../../basic_classes/courses.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _courseCodeController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    super.dispose();
  }

  // --- BACKEND CONNECTION ---
  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing.
    }

    setState(() {
      _isLoading = true;
    });

    // Access the providers with `listen: false` for a one-time action
    final userDB = Provider.of<UserDBLayer>(context, listen: false);
    final courseDB = Provider.of<CourseDBLayer>(context, listen: false);

    final currentTeacher = userDB.currentUser;
    // Safeguard to ensure a teacher is logged in
    if (currentTeacher == null || currentTeacher.role != 'Teacher') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You must be a logged-in teacher to create a course.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Create the new Courses object
    final newCourse = Courses(
      courseId: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
      courseName: _courseNameController.text.trim(),
      courseCode: _courseCodeController.text.trim().toUpperCase(), // Often course codes are uppercase
      teacherId: currentTeacher.userId, // Automatically link to the logged-in teacher
    );

    // Add the new course to the database
    courseDB.addToHive(newCourse);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course "${newCourse.courseName}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Pop the screen to return to the teacher's course list
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Create New Course'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Enter the details for the new course you will be teaching.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                hintText: 'e.g., Introduction to Flutter Development',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a course name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _courseCodeController,
              decoration: const InputDecoration(
                labelText: 'Course Code',
                hintText: 'e.g., CS492',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a course code' : null,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _createCourse,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Create Course'),
                  ),
          ],
        ),
      ),
    );
  }
}