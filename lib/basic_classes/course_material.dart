// lib/basic_classes/course_material.dart
import 'dart:typed_data';

// Re-using the ContentType enum from shared_content.dart
import 'shared_content.dart';

class CourseMaterial {
  final String materialId;
  final String courseId;
  final String? contentId; // For linking to a FlashcardSet
  final ContentType contentType;
  final String fileName;
  final Uint8List? fileData; // For uploaded documents
  final String uploadedByTeacherId;
  final DateTime uploadedAt;

  CourseMaterial({
    required this.materialId,
    required this.courseId,
    this.contentId,
    required this.contentType,
    required this.fileName,
    this.fileData,
    required this.uploadedByTeacherId,
    required this.uploadedAt,
  });

  factory CourseMaterial.fromJson(Map<String, dynamic> json) {
    return CourseMaterial(
      materialId: json['material_id'] as String,
      courseId: json['course_id'] as String,
      contentId: json['content_id'] as String?,
      contentType: ContentType.values.firstWhere((e) => e.toString() == json['content_type']),
      fileName: json['file_name'] as String,
      fileData: json['file_data'] != null ? Uint8List.fromList(List<int>.from(json['file_data'])) : null,
      uploadedByTeacherId: json['uploaded_by_teacher_id'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'course_id': courseId,
      'content_id': contentId,
      'content_type': contentType.toString(),
      'file_name': fileName,
      'file_data': fileData,
      'uploaded_by_teacher_id': uploadedByTeacherId,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
