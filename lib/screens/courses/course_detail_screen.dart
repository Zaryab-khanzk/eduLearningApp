// lib/screens/courses/course_detail_screen.dart

// ignore_for_file: unused_import, unused_element_parameter

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

// Import your universal file service
import '../../services/file_service.dart';

// Import DB Layers
import '../../dbLayer/courses_dbLayer.dart';
import '../../dbLayer/course_review_dbLayer.dart';
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/course_material_dbLayer.dart';
import '../../dbLayer/flashcard_set_dbLayer.dart';
import '../../dbLayer/course_enrollment_dbLayer.dart';
import '../../dbLayer/announcement_dbLayer.dart';

// Import Models
import '../../basic_classes/course_review.dart';
import '../../basic_classes/course_material.dart';
import '../../basic_classes/shared_content.dart' show ContentType;
import '../../basic_classes/course_enrollment.dart';
import '../../basic_classes/announcement.dart';

// Import Screens
import 'add_edit_review_screen.dart';
import 'course_list_screen.dart'; // For the StarRating helper
import '../flashcards/flashcard_view_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseDB = Provider.of<CourseDBLayer>(context, listen: false);
    final course = courseDB.getDataById(widget.courseId);

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Course not found.')),
      );
    }

    // Wrap the entire Scaffold in a Consumer to access currentUser reactively
    return Consumer<UserDBLayer>(
      builder: (context, userDB, child) {
        // Move the role check inside the Consumer
        final currentUser = userDB.currentUser;
        final bool isStudent = (currentUser?.role.toLowerCase() == 'student');

        debugPrint('🔍 CourseDetailScreen Debug:');
        debugPrint('   - currentUser: ${currentUser?.name}');
        debugPrint('   - role: "${currentUser?.role}"');
        debugPrint(
          '   - role.toLowerCase(): "${currentUser?.role.toLowerCase()}"',
        );
        debugPrint('   - isStudent: $isStudent');
        debugPrint('   - Will show enrollment button: $isStudent');

        return Scaffold(
          appBar: AppBar(
            title: Text(course.courseName),
            actions: [
              // Only show this section if the user is a student
              if (isStudent)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Consumer<CourseEnrollmentDBLayer>(
                    builder: (context, enrollmentDB, child) {
                      final isEnrolled = enrollmentDB.enrollments.any(
                        (e) =>
                            e.courseId == widget.courseId &&
                            e.studentId == userDB.currentUser!.userId,
                      );

                      if (isEnrolled) {
                        return const Chip(
                          avatar: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text('Enrolled'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }

                      return TextButton(
                        onPressed: () {
                          final newEnrollment = CourseEnrollment(
                            enrollmentId:
                                '${widget.courseId}_${userDB.currentUser!.userId}',
                            courseId: widget.courseId,
                            studentId: userDB.currentUser!.userId,
                            enrolledAt: DateTime.now(),
                          );
                          Provider.of<CourseEnrollmentDBLayer>(
                            context,
                            listen: false,
                          ).addToHive(newEnrollment);
                        },
                        child: const Text(
                          'Join Course',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.campaign_outlined), text: 'Announcements'),
                Tab(icon: Icon(Icons.rate_review_outlined), text: 'Reviews'),
                Tab(
                  icon: Icon(Icons.folder_special_outlined),
                  text: 'Materials',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _AnnouncementsTab(courseId: widget.courseId),
              _ReviewsTab(courseId: widget.courseId),
              _OfficialMaterialsTab(courseId: widget.courseId),
            ],
          ),
          // Use the 'isStudent' boolean to control the FAB visibility
          floatingActionButton: isStudent
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            AddEditReviewScreen(courseId: widget.courseId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Add Review'),
                )
              : null,
        );
      },
    );
  }
}

// --- WIDGET FOR THE "REVIEWS" TAB (Unchanged) ---
class _ReviewsTab extends StatelessWidget {
  final String courseId;
  const _ReviewsTab({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CourseReviewDBLayer, UserDBLayer>(
      builder: (context, reviewDB, userDB, child) {
        final List<CourseReview> reviewsForThisCourse = reviewDB.reviews
            .where((review) => review.courseId == courseId)
            .toList();

        if (reviewsForThisCourse.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Be the first to leave a review!',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: reviewsForThisCourse.length,
          itemBuilder: (context, index) {
            final review = reviewsForThisCourse[index];
            final reviewer = userDB.getDataById(review.userId);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reviewer?.name ?? 'Anonymous',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        StarRating(rating: review.rating.toDouble()),
                      ],
                    ),
                    const Divider(height: 16),
                    Text(review.reviewText),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// --- WIDGET FOR THE "OFFICIAL MATERIALS" TAB (Unchanged) ---
class _OfficialMaterialsTab extends StatelessWidget {
  final String courseId;
  const _OfficialMaterialsTab({super.key, required this.courseId});

  IconData _getIconForFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _downloadFile(String fileName, Uint8List fileData) {
    /* ... same as before ... */
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CourseMaterialDBLayer, FlashcardSetDBLayer>(
      builder: (context, materialDB, setDB, child) {
        final materialsForThisCourse = materialDB.materials
            .where((m) => m.courseId == courseId)
            .toList();

        if (materialsForThisCourse.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'The teacher has not uploaded any materials for this course.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: materialsForThisCourse.length,
          itemBuilder: (context, index) {
            final material = materialsForThisCourse[index];
            String title;
            IconData icon;
            VoidCallback? onTapAction;

            if (material.contentType == ContentType.flashcardSet) {
              final set = setDB.getDataById(material.contentId ?? '');
              title = set?.title ?? 'Deleted Flashcard Set';
              icon = Icons.style;
              onTapAction = () {
                if (material.contentId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          FlashcardViewScreen(setId: material.contentId!),
                    ),
                  );
                }
              };
            } else {
              title = material.fileName;
              icon = _getIconForFileName(material.fileName);
              onTapAction = () {
                if (material.fileData != null) {
                  _downloadFile(material.fileName, material.fileData!);
                }
              };
            }

            return Card(
              child: ListTile(
                leading: Icon(icon),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Uploaded on: ${material.uploadedAt.toLocal().toString().substring(0, 10)}',
                ),
                onTap: onTapAction,
              ),
            );
          },
        );
      },
    );
  }
}

class _AnnouncementsTab extends StatelessWidget {
  final String courseId;
  const _AnnouncementsTab({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnouncementDBLayer>(
      builder: (context, announcementDB, child) {
        final courseAnnouncements = announcementDB.announcements
            .where((a) => a.courseId == courseId)
            .toList();

        if (courseAnnouncements.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No announcements have been posted for this course.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(8.0),
          itemCount: courseAnnouncements.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final announcement = courseAnnouncements[index];
            return ListTile(
              leading: const Icon(Icons.campaign),
              title: Text(announcement.message),
              subtitle: Text(
                'Posted on: ${announcement.createdAt.toLocal().toString().substring(0, 10)}',
              ),
            );
          },
        );
      },
    );
  }
}
