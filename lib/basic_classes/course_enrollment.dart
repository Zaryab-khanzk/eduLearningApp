// lib/basic_classes/course_enrollment.dart

class CourseEnrollment {
  final String enrollmentId; // A unique ID for the enrollment itself
  final String courseId;
  final String studentId;
  final DateTime enrolledAt;

  CourseEnrollment({
    required this.enrollmentId,
    required this.courseId,
    required this.studentId,
    required this.enrolledAt,
  });

  factory CourseEnrollment.fromJson(Map<String, dynamic> json) {
    return CourseEnrollment(
      enrollmentId: json['enrollment_id'] as String,
      courseId: json['course_id'] as String,
      studentId: json['student_id'] as String,
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollment_id': enrollmentId,
      'course_id': courseId,
      'student_id': studentId,
      'enrolled_at': enrolledAt.toIso8601String(),
    };
  }
}