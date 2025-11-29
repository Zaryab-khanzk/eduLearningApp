// lib/screens/teacher/roster_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/course_enrollment_dbLayer.dart';
import '../../dbLayer/users_dbLayer.dart';
import '../../basic_classes/courses.dart';

class RosterScreen extends StatelessWidget {
  final Courses course;
  const RosterScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roster for "${course.courseName}"'),
      ),
      body: Consumer2<CourseEnrollmentDBLayer, UserDBLayer>(
        builder: (context, enrollmentDB, userDB, child) {
          // 1. Get all student IDs enrolled in this course
          final studentIds = enrollmentDB.enrollments
              .where((e) => e.courseId == course.courseId)
              .map((e) => e.studentId)
              .toList();

          if (studentIds.isEmpty) {
            return const Center(child: Text('No students have joined this course yet.'));
          }

          // 2. Look up the user object for each student ID
          final students = studentIds
              .map((id) => userDB.getDataById(id))
              .where((user) => user != null)
              .toList();

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index]!;
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(student.name),
                subtitle: Text(student.email),
              );
            },
          );
        },
      ),
    );
  }
}