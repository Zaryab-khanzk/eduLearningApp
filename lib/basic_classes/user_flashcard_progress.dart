class UserFlashcardProgress {
  final String progressId;
  final String userId;
  final String cardId; // Assuming you'll have a separate Flashcard class for individual cards
  final int totalAttempts;
  final int correctAttempts;
  final DateTime lastAttempt;

  UserFlashcardProgress({
    required this.progressId,
    required this.userId,
    required this.cardId,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.lastAttempt,
  });

  factory UserFlashcardProgress.fromJson(Map<String, dynamic> json) {
    return UserFlashcardProgress(
      progressId: json['progress_id'] as String,
      userId: json['user_id'] as String,
      cardId: json['card_id'] as String,
      totalAttempts: json['total_attempts'] as int,
      correctAttempts: json['correct_attempts'] as int,
      lastAttempt: DateTime.parse(json['last_attempt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'progress_id': progressId,
      'user_id': userId,
      'card_id': cardId,
      'total_attempts': totalAttempts,
      'correct_attempts': correctAttempts,
      'last_attempt': lastAttempt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserFlashcardProgress(progressId: $progressId, userId: $userId, cardId: $cardId, totalAttempts: $totalAttempts)';
  }
}