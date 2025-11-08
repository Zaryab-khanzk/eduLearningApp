class FlashcardSets {
  final int setId;
  final String title;
  final String description;
  final String createdBy;
  final DateTime createdAt;

  FlashcardSets({
    required this.setId,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdAt,
  });

  // Factory constructor to create an object from JSON
  factory FlashcardSets.fromJson(Map<String, dynamic> json) {
    return FlashcardSets(
      setId: json['set_id'],
      title: json['title'],
      description: json['description'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'set_id': setId,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Override toString for better readability
  @override
  String toString() {
    return 'FlashcardSets(setId: $setId, title: $title, description: $description, createdBy: $createdBy, createdAt: $createdAt)';
  }
}
