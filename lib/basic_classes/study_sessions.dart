class StudySession {
  final String sessionId;
  final String groupId;
  final String topic;
  final DateTime scheduledTime;
  final String notes;

  StudySession({
    required this.sessionId,
    required this.groupId,
    required this.topic,
    required this.scheduledTime,
    required this.notes,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      sessionId: json['session_id'] as String,
      groupId: json['group_id'] as String,
      topic: json['topic'] as String,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      notes: json['notes'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'group_id': groupId,
      'topic': topic,
      'scheduled_time': scheduledTime.toIso8601String(),
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'StudySession(sessionId: $sessionId, groupId: $groupId, topic: $topic, scheduledTime: $scheduledTime)';
  }
}