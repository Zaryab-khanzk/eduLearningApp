class CourseReview {
  final String reviewId;
  final String courseId;
  final String userId; // Foreign Key to User (role = 'Student')
  final int rating;
  final String reviewText;

  CourseReview({
    required this.reviewId,
    required this.courseId,
    required this.userId,
    required this.rating,
    required this.reviewText,
  });

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    return CourseReview(
      reviewId: json['review_id'] as String,
      courseId: json['course_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      reviewText: json['review_text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'course_id': courseId,
      'user_id': userId,
      'rating': rating,
      'review_text': reviewText,
    };
  }

  @override
  String toString() {
    return 'CourseReview(reviewId: $reviewId, courseId: $courseId, rating: $rating)';
  }
}