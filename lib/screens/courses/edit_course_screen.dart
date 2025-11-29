// lib/screens/courses/edit_course_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/courses_dbLayer.dart';
import '../../basic_classes/courses.dart';

class EditCourseScreen extends StatefulWidget {
  final Courses course;

  const EditCourseScreen({
    super.key,
    required this.course,
  });

  @override
  _EditCourseScreenState createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _courseNameController;
  late TextEditingController _courseCodeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate the form fields with the existing course data
    _courseNameController = TextEditingController(text: widget.course.courseName);
    _courseCodeController = TextEditingController(text: widget.course.courseCode);
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    super.dispose();
  }

  Future<void> _updateCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final courseDB = Provider.of<CourseDBLayer>(context, listen: false);

    // Create a new Courses object with the updated details but the same IDs
    final updatedCourse = Courses(
      courseId: widget.course.courseId, // Keep the original ID
      courseName: _courseNameController.text.trim(),
      courseCode: _courseCodeController.text.trim().toUpperCase(),
      teacherId: widget.course.teacherId, // Keep the original teacher ID
    );

    // Call the existing updateFromHive method
    courseDB.updateFromHive(updatedCourse);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course "${updatedCourse.courseName}" updated successfully!'),
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
        title: const Text('Edit Course'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a course name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _courseCodeController,
              decoration: const InputDecoration(
                labelText: 'Course Code',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a course code' : null,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _updateCourse,
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