// lib/screens/teacher/manage_announcements_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/announcement_dbLayer.dart';
import '../../dbLayer/users_dbLayer.dart';
import '../../basic_classes/announcement.dart';
import '../../basic_classes/courses.dart';

class ManageAnnouncementsScreen extends StatefulWidget {
  final Courses course;
  const ManageAnnouncementsScreen({super.key, required this.course});

  @override
  State<ManageAnnouncementsScreen> createState() => _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState extends State<ManageAnnouncementsScreen> {
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _postAnnouncement() {
    if (!_formKey.currentState!.validate()) return;

    final announcementDB = Provider.of<AnnouncementDBLayer>(context, listen: false);
    final userDB = Provider.of<UserDBLayer>(context, listen: false);

    final newAnnouncement = Announcement(
      announcementId: DateTime.now().millisecondsSinceEpoch.toString(),
      courseId: widget.course.courseId,
      teacherId: userDB.currentUser!.userId,
      message: _messageController.text.trim(),
      createdAt: DateTime.now(),
    );

    announcementDB.addToHive(newAnnouncement);
    _messageController.clear(); // Clear the text field after posting
    FocusScope.of(context).unfocus(); // Dismiss the keyboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements for "${widget.course.courseName}"'),
      ),
      body: Column(
        children: [
          // List of past announcements
          Expanded(
            child: Consumer<AnnouncementDBLayer>(
              builder: (context, announcementDB, child) {
                final courseAnnouncements = announcementDB.announcements
                    .where((a) => a.courseId == widget.course.courseId)
                    .toList();
                
                if (courseAnnouncements.isEmpty) {
                  return const Center(child: Text('No announcements posted yet.'));
                }

                return ListView.builder(
                  itemCount: courseAnnouncements.length,
                  itemBuilder: (context, index) {
                    final announcement = courseAnnouncements[index];
                    return ListTile(
                      title: Text(announcement.message),
                      subtitle: Text('Posted on: ${announcement.createdAt.toLocal().toString().substring(0, 10)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          announcementDB.deleteFromHive(announcement.announcementId);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Form to create a new announcement
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your announcement...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.trim().isEmpty ? 'Cannot be empty' : null,
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _postAnnouncement,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}