class GroupMember {
  final String memberId;
  final String userId;
  final String memberNames; // Usually derived from User.name, but kept as requested
  final String groupId;
  final String role; // Role within the group (e.g., 'Leader', 'Member')
  final DateTime joinedAt;

  GroupMember({
    required this.memberId,
    required this.userId,
    required this.memberNames,
    required this.groupId,
    required this.role,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      memberId: json['member_id'] as String,
      userId: json['user_id'] as String,
      memberNames: json['member_names'] as String,
      groupId: json['group_id'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'user_id': userId,
      'member_names': memberNames,
      'group_id': groupId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'GroupMember(memberId: $memberId, userId: $userId, groupId: $groupId, role: $role)';
  }
}