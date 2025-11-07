class Course {
  String courseId;
  String courseCode;
  String courseName;
  String professorName;

  // Constructor
  Course({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.professorName,
  });

  // Convert object to JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_code': courseCode,
      'course_name': courseName,
      'professor_name': professorName,
    };
  }

  // Create object from JSON (Map)
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['course_id'],
      courseCode: json['course_code'],
      courseName: json['course_name'],
      professorName: json['professor_name'],
    );
  }

  // toString method for easy printing
  @override
  String toString() {
    return 'Course(courseId: $courseId, courseCode: $courseCode, courseName: $courseName, professorName: $professorName)';
  }
}
