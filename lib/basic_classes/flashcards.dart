class Flashcard {
  final String cardId;
  final String setId;
  final String question;
  final String answer;
  final int difficulty; // e.g., 1 (Easy) to 5 (Hard)
  final DateTime lastReviewed;

  Flashcard({
    required this.cardId,
    required this.setId,
    required this.question,
    required this.answer,
    required this.difficulty,
    required this.lastReviewed,
  });

  // Factory constructor to create a Flashcard from a JSON Map (Deserialization)
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      cardId: json['card_id'] as String,
      setId: json['set_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      difficulty: json['difficulty'] as int,
      lastReviewed: DateTime.parse(json['last_reviewed'] as String),
    );
  }

  // Method to convert a Flashcard object to a JSON Map (Serialization)
  Map<String, dynamic> toJson() {
    return {
      'card_id': cardId,
      'set_id': setId,
      'question': question,
      'answer': answer,
      'difficulty': difficulty,
      'last_reviewed': lastReviewed.toIso8601String(),
    };
  }

  // Method to provide a helpful string representation for debugging
  @override
  String toString() {
    return 'Flashcard(cardId: $cardId, setId: $setId, question: "${question.substring(0, question.length > 20 ? 20 : question.length)}...", difficulty: $difficulty)';
  }
}