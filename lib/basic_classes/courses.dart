class Courses {
  final String courseId;
  final String courseCode;
  final String courseName;
  final String teacherId; // Foreign Key to User (role = 'Teacher')

  Courses({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.teacherId,
  });

  factory Courses.fromJson(Map<String, dynamic> json) {
    return Courses(
      courseId: json['course_id'] as String,
      courseCode: json['course_code'] as String,
      courseName: json['course_name'] as String,
      teacherId: json['teacher_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_code': courseCode,
      'course_name': courseName,
      'teacher_id': teacherId,
    };
  }

  @override
  String toString() {
    return 'Course(courseId: $courseId, code: $courseCode, name: $courseName, teacherId: $teacherId)';
  }
}