// lib/models/test_session.dart

class TestSession {
  final String sessionId;
  final String userId;
  final String setId;
  final DateTime completedAt;
  final int totalQuestions;
  final int correctAnswers;
  final List<String> incorrectCardIds;

  TestSession({
    required this.sessionId,
    required this.userId,
    required this.setId,
    required this.completedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectCardIds,
  });

  factory TestSession.fromJson(Map<String, dynamic> json) {
    return TestSession(
      sessionId: json['session_id'] as String,
      userId: json['user_id'] as String,
      setId: json['set_id'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      // Ensure we correctly convert from List<dynamic> to List<String>
      incorrectCardIds: List<String>.from(json['incorrect_card_ids'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'set_id': setId,
      'completed_at': completedAt.toIso8601String(),
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'incorrect_card_ids': incorrectCardIds,
    };
  }

  @override
  String toString() {
    return 'TestSession(sessionId: $sessionId, userId: $userId, setId: $setId, score: $correctAnswers/$totalQuestions)';
  }
}