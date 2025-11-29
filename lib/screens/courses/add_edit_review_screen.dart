// lib/screens/courses/add_edit_review_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import the required DB layers and models
import '../../dbLayer/course_review_dbLayer.dart';
import '../../dbLayer/users_dbLayer.dart';
import '../../basic_classes/course_review.dart';

class AddEditReviewScreen extends StatefulWidget {
  final String courseId;

  const AddEditReviewScreen({
    super.key,
    required this.courseId,
  });

  @override
  _AddEditReviewScreenState createState() => _AddEditReviewScreenState();
}

class _AddEditReviewScreenState extends State<AddEditReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewTextController = TextEditingController();

  // State variables to manage the form input
  int _rating = 0; // 0 means no rating has been selected yet
  bool _isLoading = false;

  @override
  void dispose() {
    // Always dispose of controllers to prevent memory leaks
    _reviewTextController.dispose();
    super.dispose();
  }

  // --- BACKEND CONNECTION ---
  Future<void> _submitReview() async {
    // First, validate the text field
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Then, validate that a star rating has been chosen
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Access the necessary providers. `listen: false` is used for one-time actions.
    final reviewDB = Provider.of<CourseReviewDBLayer>(context, listen: false);
    final userDB = Provider.of<UserDBLayer>(context, listen: false);

    // Get the currently logged-in user's ID
    final loggedInUser = userDB.currentUser;
    if (loggedInUser == null) {
      // This is a safeguard; this screen shouldn't be accessible if no one is logged in.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You must be logged in to leave a review.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Create the CourseReview object with the form data
    final newReview = CourseReview(
      reviewId: DateTime.now().millisecondsSinceEpoch.toString(), // A simple unique ID
      courseId: widget.courseId,
      userId: loggedInUser.userId,
      rating: _rating,
      reviewText: _reviewTextController.text.trim(),
    );

    // Access the CourseReviewDBLayer and call the addToHive method
    reviewDB.addToHive(newReview);

    // After successfully saving, show a confirmation and pop the screen to return.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your review has been submitted!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Your Review'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- UI Component: Star Rating Selector ---
            const Text(
              'Select Your Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    // When a star is tapped, update the state
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  icon: Icon(
                    // If the index is less than the rating, show a full star
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // --- UI Component: TextField for the review ---
            TextFormField(
              controller: _reviewTextController,
              decoration: const InputDecoration(
                labelText: 'Your written review',
                hintText: 'Share details of your own experience at this course...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true, // Good for multi-line text fields
              ),
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please write a review before submitting.';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // --- UI Component: Submit Button ---
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Submit Review'),
                  ),
          ],
        ),
      ),
    );
  }
}