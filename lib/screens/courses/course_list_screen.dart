// lib/screens/courses/course_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import all the DB layers you need to fetch and cross-reference data
import '../../dbLayer/courses_dbLayer.dart';
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/course_review_dbLayer.dart';
import '../../basic_classes/courses.dart';

// Import the detail screen for navigation
import 'course_detail_screen.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- BACKEND CONNECTION: Get Data ---
    // Access the providers. Using `context` here means this widget will
    // rebuild whenever notifyListeners() is called in these providers.
    final courseDB = Provider.of<CourseDBLayer>(context);
    final userDB = Provider.of<UserDBLayer>(context);
    final reviewDB = Provider.of<CourseReviewDBLayer>(context);

    // Get the full list of courses from the database layer.
    final List<Courses> allCourses = courseDB.courses;

    // --- UI COMPONENTS ---
    return Scaffold(
      // Check if there are no courses to display
      body: allCourses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No courses have been added yet.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: allCourses.length,
              itemBuilder: (context, index) {
                final course = allCourses[index];

                // --- DATA PROCESSING AND LOOKUPS ---

                // 1. Display Teacher's Name: Look up the user's name from the teacherId
                final teacher = userDB.getDataById(course.teacherId);
                final teacherName = teacher?.name ?? 'Unknown Instructor';

                // 2. Display Average Rating: Calculate it manually for this course
                final courseReviews = reviewDB.reviews
                    .where((review) => review.courseId == course.courseId)
                    .toList();

                double averageRating = 0.0;
                if (courseReviews.isNotEmpty) {
                  // Sum all ratings and divide by the number of reviews
                  averageRating =
                      courseReviews
                          .map((r) => r.rating)
                          .reduce((a, b) => a + b) /
                      courseReviews.length;
                }

                // --- LIST ITEM UI ---
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: const Icon(Icons.school_outlined),
                    ),
                    title: Text(
                      course.courseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Instructor: $teacherName'),
                        const SizedBox(height: 4),
                        // Use a helper widget to display the stars
                        StarRating(
                          rating: averageRating,
                          reviewCount: courseReviews.length,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    // --- NAVIGATION ---
                    onTap: () {
                      // When the user taps, navigate to the detail screen,
                      // passing the unique courseId.
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              CourseDetailScreen(courseId: course.courseId),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      // Optional: Add a FloatingActionButton for Teachers to add new courses
      // floatingActionButton: _buildAddCourseButton(context),
    );
  }

  // Example of role-based UI. You could implement this if you want.
  /*
  Widget _buildAddCourseButton(BuildContext context) {
    final userDB = Provider.of<UserDBLayer>(context, listen: false);
    if (userDB.currentUser?.role == 'Teacher') {
      return FloatingActionButton(
        onPressed: () {
          // Navigate to an AddCourseScreen
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Course',
      );
    }
    return Container(); // Return an empty container if user is not a teacher
  }
  */
}

// --- HELPER WIDGET for displaying stars ---
class StarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const StarRating({super.key, required this.rating, this.reviewCount = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          IconData icon;
          if (index >= rating) {
            icon = Icons.star_border;
          } else if (index > rating - 1 && index < rating) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star;
          }
          return Icon(icon, color: Colors.amber, size: 18);
        }),
        const SizedBox(width: 4),
        Text(
          '(${reviewCount.toString()})',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }
}
