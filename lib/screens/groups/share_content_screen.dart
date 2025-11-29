// lib/screens/groups/share_content_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

// Import necessary DB layers and models
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/flashcard_set_dbLayer.dart';
import '../../dbLayer/shared_content_db_layer.dart';
import '../../basic_classes/flashcard_set.dart';
import '../../basic_classes/shared_content.dart';

class ShareContentScreen extends StatefulWidget {
  final String groupId;

  const ShareContentScreen({super.key, required this.groupId});

  @override
  State<ShareContentScreen> createState() => _ShareContentScreenState();
}

class _ShareContentScreenState extends State<ShareContentScreen> {
  bool _isLoading = false;

  // Logic for sharing an existing Flashcard Set
  void _shareSet(BuildContext context, FlashcardSet setToShare) {
    final userDB = Provider.of<UserDBLayer>(context, listen: false);
    final sharedDB = Provider.of<SharedContentDBLayer>(context, listen: false);

    final newSharedItem = SharedContent(
      sharedContentId: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: widget.groupId,
      contentId: setToShare.setId,
      contentType: ContentType.flashcardSet,
      sharedByUserId: userDB.currentUser!.userId,
      sharedAt: DateTime.now(),
      fileName: setToShare.title, // Use set title as the name
      fileData: null, // No file data for a flashcard set
    );

    sharedDB.addToHive(newSharedItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${setToShare.title}" shared successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  // Web-compatible logic for uploading a document
  Future<void> _uploadDocument() async {
    setState(() => _isLoading = true);
    try {
      // Pick a file and read its bytes into memory
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png'],
        withData: true, // This is crucial for web
      );

      if (result != null) {
        final fileName = result.files.single.name;
        final fileBytes = result.files.single.bytes;

        if (fileBytes == null) {
          throw Exception("Could not read file data.");
        }

        final userDB = Provider.of<UserDBLayer>(context, listen: false);
        final sharedDB = Provider.of<SharedContentDBLayer>(
          context,
          listen: false,
        );
        final newSharedItem = SharedContent(
          sharedContentId: DateTime.now().millisecondsSinceEpoch.toString(),
          groupId: widget.groupId,
          contentType: ContentType.lectureNote,
          sharedByUserId: userDB.currentUser!.userId,
          sharedAt: DateTime.now(),
          fileName: fileName,
          fileData: fileBytes, // Store the bytes directly in the object
          contentId: null,
        );

        sharedDB.addToHive(newSharedItem);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File "$fileName" uploaded and shared!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // User canceled the picker
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error uploading file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Content')),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing file...'),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload a Lecture Note'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _uploadDocument,
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Or Share One of Your Flashcard Sets:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Consumer2<UserDBLayer, FlashcardSetDBLayer>(
                    builder: (context, userDB, setDB, child) {
                      final currentUser = userDB.currentUser!;
                      final List<FlashcardSet> mySets = setDB.sets
                          .where((set) => set.createdBy == currentUser.userId)
                          .toList();

                      if (mySets.isEmpty) {
                        return const Center(
                          child: Text(
                            'You have not created any flashcard sets to share.',
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        itemCount: mySets.length,
                        itemBuilder: (context, index) {
                          final set = mySets[index];
                          return Card(
                            child: ListTile(
                              title: Text(set.title),
                              trailing: ElevatedButton(
                                child: const Text('Share'),
                                onPressed: () => _shareSet(context, set),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
