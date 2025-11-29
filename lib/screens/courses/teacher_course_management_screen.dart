// lib/screens/courses/teacher_course_management_screen.dart

// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import DB Layers
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/courses_dbLayer.dart';
import '../../dbLayer/course_enrollment_dbLayer.dart';
import '../../dbLayer/course_material_dbLayer.dart';
import '../../dbLayer/announcement_dbLayer.dart';

// Import Models
import '../../basic_classes/courses.dart';

// Import Screens
import 'add_course_screen.dart';
import 'edit_course_screen.dart';
import 'manage_materials_screen.dart';
import '../teacher/roster_screen.dart';
import '../teacher/analytics_screen.dart';
import '../teacher/manage_announcements_screen.dart'; // <<<--- IMPORT THE NEW SCREEN

class TeacherCourseManagementScreen extends StatelessWidget {
  const TeacherCourseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDB = Provider.of<UserDBLayer>(context);
    final courseDB = Provider.of<CourseDBLayer>(context);
    final enrollmentDB = Provider.of<CourseEnrollmentDBLayer>(context);
    final materialDB = Provider.of<CourseMaterialDBLayer>(context);
    final announcementDB = Provider.of<AnnouncementDBLayer>(context);

    final loggedInTeacherId = userDB.currentUser?.userId;

    if (loggedInTeacherId == null) {
      return const Center(child: Text('Error: Not logged in as a teacher.'));
    }

    final List<Courses> myCourses = courseDB.courses
        .where((course) => course.teacherId == loggedInTeacherId)
        .toList();

    return Scaffold(
      body: myCourses.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'You have not created any courses yet. Tap the + button to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: myCourses.length,
              itemBuilder: (context, index) {
                final course = myCourses[index];

                 final studentCount = enrollmentDB.enrollments
                    .where((e) => e.courseId == course.courseId)
                    .length;
                final materialCount = materialDB.materials
                    .where((m) => m.courseId == course.courseId)
                    .length;
                final announcementCount = announcementDB.announcements
                    .where((a) => a.courseId == course.courseId)
                    .length;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color.fromARGB(255, 121, 196, 189),
                              child: const Icon(Icons.book_outlined),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.courseName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Course Code: ${course.courseCode}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (String value) {
                                if (value == 'announcements') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ManageAnnouncementsScreen(course: course),
                                  ));
                                } else if (value == 'edit') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => EditCourseScreen(course: course),
                                  ));
                                } else if (value == 'materials') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ManageMaterialsScreen(course: course),
                                  ));
                                } else if (value == 'roster') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => RosterScreen(course: course),
                                  ));
                                } else if (value == 'analytics') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AnalyticsScreen(course: course),
                                  ));
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) => AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: Text('Are you sure you want to delete "${course.courseName}"? This will also delete all student reviews for this course and cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () => Navigator.of(dialogContext).pop(),
                                        ),
                                        TextButton(
                                          child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                                          onPressed: () {
                                            courseDB.deleteCourseAndData(course.courseId);
                                            Navigator.of(dialogContext).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'announcements',
                          child: ListTile(leading: Icon(Icons.campaign), title: Text('Announcements')),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
                        ),
                        const PopupMenuItem<String>(
                          value: 'materials',
                          child: ListTile(leading: Icon(Icons.folder), title: Text('Manage Materials')),
                        ),
                        const PopupMenuItem<String>(
                          value: 'roster',
                          child: ListTile(leading: Icon(Icons.people), title: Text('View Roster')),
                        ),
                        const PopupMenuItem<String>(
                          value: 'analytics',
                          child: ListTile(leading: Icon(Icons.bar_chart), title: Text('View Analytics')),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(leading: Icon(Icons.delete_forever, color: Colors.red), title: Text('Delete')),
                        ),
                      ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatChip(icon: Icons.people_outline, label: '$studentCount Students'),
                            _StatChip(icon: Icons.folder_open, label: '$materialCount Materials'),
                            _StatChip(icon: Icons.campaign_outlined, label: '$announcementCount Posts'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddCourseScreen(),
            ),
          );
        },
        tooltip: 'Add New Course',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.black54),
      label: Text(label),
      padding: EdgeInsets.zero,
      labelStyle: const TextStyle(fontSize: 12),
      backgroundColor: const Color.fromARGB(255, 120, 167, 189),
    );
  }
}