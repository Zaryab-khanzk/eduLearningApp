class FlashcardSet {
  final String setId;
  final String title;
  final String description;
  final String createdBy; // Foreign Key to User ID
  final DateTime createdAt;

  FlashcardSet({
    required this.setId,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    return FlashcardSet(
      setId: json['set_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set_id': setId,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'FlashcardSet(setId: $setId, title: $title, createdBy: $createdBy)';
  }
}