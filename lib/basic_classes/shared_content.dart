// lib/basic_classes/shared_content.dart
import 'dart:typed_data'; // Import for Uint8List

// An enum to differentiate between content types in the future
enum ContentType { flashcardSet, lectureNote }

class SharedContent {
  final String sharedContentId;
  final String groupId; // Link to the StudyGroup
  final String? contentId; // Nullable, used for things like flashcard sets
  final ContentType contentType;
  final String sharedByUserId;
  final DateTime sharedAt;
  final String fileName; // e.g., "Lecture_Week_5.pdf" or the flashcard set title

  // --- CHANGE: filePath is now fileData ---
  final Uint8List? fileData; // Storing the actual file content as bytes. Nullable for flashcard sets.

  SharedContent({
    required this.sharedContentId,
    required this.groupId,
    this.contentId,
    required this.contentType,
    required this.sharedByUserId,
    required this.sharedAt,
    required this.fileName,
    this.fileData,
  });

  factory SharedContent.fromJson(Map<String, dynamic> json) {
    return SharedContent(
      sharedContentId: json['shared_content_id'] as String,
      groupId: json['group_id'] as String,
      contentId: json['content_id'] as String?,
      contentType: ContentType.values.firstWhere(
            (e) => e.toString() == json['content_type'],
            orElse: () => ContentType.flashcardSet), // Default fallback
      sharedByUserId: json['shared_by_user_id'] as String,
      sharedAt: DateTime.parse(json['shared_at'] as String),
      fileName: json['file_name'] as String,
      // --- CHANGE: Handle byte data from JSON (which is a List<dynamic>) ---
      fileData: json['file_data'] != null ? Uint8List.fromList(List<int>.from(json['file_data'])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shared_content_id': sharedContentId,
      'group_id': groupId,
      'content_id': contentId,
      'content_type': contentType.toString(),
      'shared_by_user_id': sharedByUserId,
      'shared_at': sharedAt.toIso8601String(),
      'file_name': fileName,
      // --- CHANGE: Store byte data ---
      'file_data': fileData,
    };
  }
}