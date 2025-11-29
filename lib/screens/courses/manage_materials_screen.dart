// lib/screens/courses/manage_materials_screen.dart

// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

// Import necessary DB layers and models from your project structure
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/flashcard_set_dbLayer.dart';
import '../../dbLayer/course_material_dbLayer.dart';
import '../../basic_classes/flashcard_set.dart';
import '../../basic_classes/course_material.dart';
import '../../basic_classes/shared_content.dart'; // For the ContentType enum
import '../../basic_classes/courses.dart';

class ManageMaterialsScreen extends StatefulWidget {
  final Courses course;
  const ManageMaterialsScreen({super.key, required this.course});

  @override
  State<ManageMaterialsScreen> createState() => _ManageMaterialsScreenState();
}

class _ManageMaterialsScreenState extends State<ManageMaterialsScreen> {
  bool _isLoading = false;

  // --- Backend logic for uploading a new document ---
  Future<void> _uploadDocument() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png'],
        withData: true, // Crucial for web and mobile compatibility
      );

      if (result != null) {
        final fileName = result.files.single.name;
        final fileBytes = result.files.single.bytes;
        if (fileBytes == null) throw Exception("Could not read file data.");

        final userDB = Provider.of<UserDBLayer>(context, listen: false);
        final materialDB = Provider.of<CourseMaterialDBLayer>(context, listen: false);

        final newMaterial = CourseMaterial(
          materialId: DateTime.now().millisecondsSinceEpoch.toString(),
          courseId: widget.course.courseId,
          contentType: ContentType.lectureNote,
          fileName: fileName,
          fileData: fileBytes,
          uploadedByTeacherId: userDB.currentUser!.userId,
          uploadedAt: DateTime.now(),
          contentId: null,
        );

        materialDB.addToHive(newMaterial);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File "$fileName" uploaded.'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      print("Error uploading file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Backend logic for sharing an existing flashcard set ---
  void _shareSet(BuildContext context, FlashcardSet setToShare) {
    final userDB = Provider.of<UserDBLayer>(context, listen: false);
    final materialDB = Provider.of<CourseMaterialDBLayer>(context, listen: false);

    final newMaterial = CourseMaterial(
      materialId: DateTime.now().millisecondsSinceEpoch.toString(),
      courseId: widget.course.courseId,
      contentId: setToShare.setId,
      contentType: ContentType.flashcardSet,
      fileName: setToShare.title,
      fileData: null,
      uploadedByTeacherId: userDB.currentUser!.userId,
      uploadedAt: DateTime.now(),
    );

    materialDB.addToHive(newMaterial);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Set "${setToShare.title}" shared.'), backgroundColor: Colors.green),
    );
  }

  // --- UI Helper to show the dialog for selecting a flashcard set ---
  void _showShareSetDialog() {
    final userDB = Provider.of<UserDBLayer>(context, listen: false);
    final setDB = Provider.of<FlashcardSetDBLayer>(context, listen: false);

    // Find all sets created by the current teacher
    final mySets = setDB.sets
        .where((set) => set.createdBy == userDB.currentUser!.userId)
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Share a Flashcard Set'),
          content: SizedBox(
            width: double.maxFinite,
            child: mySets.isEmpty
                ? const Text('You have not created any flashcard sets to share.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: mySets.length,
                    itemBuilder: (context, index) {
                      final set = mySets[index];
                      return ListTile(
                        title: Text(set.title),
                        onTap: () {
                          _shareSet(context, set);
                          Navigator.of(dialogContext).pop(); // Close the dialog after sharing
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materials for "${widget.course.courseName}"'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Section to manage existing materials ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Uploaded Materials', style: Theme.of(context).textTheme.titleLarge),
                ),
                Expanded(
                  child: Consumer<CourseMaterialDBLayer>(
                    builder: (context, materialDB, child) {
                      final courseMaterials = materialDB.materials
                          .where((m) => m.courseId == widget.course.courseId)
                          .toList();

                      if (courseMaterials.isEmpty) {
                        return const Center(child: Text('No materials uploaded yet.'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: courseMaterials.length,
                        itemBuilder: (context, index) {
                          final material = courseMaterials[index];
                          return Card(
                            child: ListTile(
                              title: Text(material.fileName),
                              leading: Icon(material.contentType == ContentType.flashcardSet ? Icons.style : Icons.description),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                tooltip: 'Delete Material',
                                onPressed: () {
                                  // Add delete confirmation dialog for safety
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Delete Material?'),
                                      content: Text('Are you sure you want to delete "${material.fileName}"?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () {
                                            materialDB.deleteFromHive(material.materialId);
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                
                // --- Section to add new materials ---
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Add New Material', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _uploadDocument,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload a Document'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _showShareSetDialog,
                        icon: const Icon(Icons.style_outlined),
                        label: const Text('Share an Existing Flashcard Set'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}