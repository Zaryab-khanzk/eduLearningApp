class StudyGroup {
  final String groupId;
  final String groupName;
  final String description;
  final String createdBy; // Foreign Key to User ID
  final DateTime createdAt;

  StudyGroup({
    required this.groupId,
    required this.groupName,
    required this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      groupId: json['group_id'] as String,
      groupName: json['group_name'] as String,
      description: json['description'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'group_name': groupName,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'StudyGroup(groupId: $groupId, groupName: $groupName, createdBy: $createdBy)';
  }
}