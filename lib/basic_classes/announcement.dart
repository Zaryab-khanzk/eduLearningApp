// lib/basic_classes/announcement.dart

class Announcement {
  final String announcementId;
  final String courseId;
  final String teacherId; // The ID of the teacher who posted it
  final String message;
  final DateTime createdAt;

  Announcement({
    required this.announcementId,
    required this.courseId,
    required this.teacherId,
    required this.message,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      announcementId: json['announcement_id'] as String,
      courseId: json['course_id'] as String,
      teacherId: json['teacher_id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'announcement_id': announcementId,
      'course_id': courseId,
      'teacher_id': teacherId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}