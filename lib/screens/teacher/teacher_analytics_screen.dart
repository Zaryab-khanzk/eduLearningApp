// lib/screens/teacher/teacher_analytics_screen.dart

// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/courses_dbLayer.dart';
import '../../dbLayer/course_enrollment_dbLayer.dart';
import '../../dbLayer/test_session_dbLayer.dart';

// This is the high-level dashboard showing overall stats.
class TeacherAnalyticsScreen extends StatelessWidget {
  const TeacherAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer4<UserDBLayer, CourseDBLayer, CourseEnrollmentDBLayer, TestSessionDBLayer>(
        builder: (context, userDB, courseDB, enrollmentDB, sessionDB, child) {
          final currentUser = userDB.currentUser;
          if (currentUser == null) return const Center(child: Text('Not logged in.'));

          final myCourses = courseDB.courses.where((c) => c.teacherId == currentUser.userId).toList();
          final myCourseIds = myCourses.map((c) => c.courseId).toSet();
          
          final allEnrollmentsInMyCourses = enrollmentDB.enrollments.where((e) => myCourseIds.contains(e.courseId));
          final uniqueStudentCount = allEnrollmentsInMyCourses.map((e) => e.studentId).toSet().length;
          
          final allTestSessionsForMyCourses = sessionDB.sessions.where((s) {
            // This is a more robust check: does the session's setId correspond to a courseId that has this set as official material?
            // For now, we'll assume a direct link for simplicity. You can enhance this later.
            return myCourseIds.contains(s.setId); 
          });
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Overall Dashboard', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _StatCard(title: 'Total Courses', value: myCourses.length.toString(), icon: Icons.video_library)),
                  const SizedBox(width: 16),
                  Expanded(child: _StatCard(title: 'Unique Students', value: uniqueStudentCount.toString(), icon: Icons.people)),
                ],
              ),
              const SizedBox(height: 16),
              _StatCard(title: 'Total Tests Taken', value: allTestSessionsForMyCourses.length.toString(), icon: Icons.quiz, color: Colors.blue.shade100),
            ],
          );
        },
      ),
    );
  }
}

// Helper widget for a consistent stat card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  const _StatCard({super.key, required this.title, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? const Color.fromARGB(255, 75, 154, 160),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}