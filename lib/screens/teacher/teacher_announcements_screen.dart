// lib/screens/teacher/teacher_announcements_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/announcement_dbLayer.dart';
import '../../dbLayer/courses_dbLayer.dart';
import '../../dbLayer/users_dbLayer.dart';
import '../../basic_classes/announcement.dart';

// This is the "hub" screen that shows announcements from ALL of the teacher's courses.
class TeacherAnnouncementsScreen extends StatelessWidget {
  const TeacherAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<AnnouncementDBLayer, CourseDBLayer, UserDBLayer>(
        builder: (context, announcementDB, courseDB, userDB, child) {
          final currentUser = userDB.currentUser;
          if (currentUser == null) return const Center(child: Text('Not logged in.'));

          final myCourseIds = courseDB.courses
              .where((c) => c.teacherId == currentUser.userId)
              .map((c) => c.courseId)
              .toSet();

          final List<Announcement> myAnnouncements = announcementDB.announcements
              .where((a) => myCourseIds.contains(a.courseId))
              .toList();

          if (myAnnouncements.isEmpty) {
            return const Center(
              child: Text(
                'You have not posted any announcements.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: myAnnouncements.length,
            itemBuilder: (context, index) {
              final announcement = myAnnouncements[index];
              final course = courseDB.getDataById(announcement.courseId);

              return Card(
                child: ListTile(
                  title: Text(announcement.message),
                  subtitle: Text(
                    'Posted to "${course?.courseName ?? 'Unknown Course'}" on ${announcement.createdAt.toLocal().toString().substring(0, 10)}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}