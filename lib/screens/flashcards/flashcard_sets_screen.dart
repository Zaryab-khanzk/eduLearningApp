// lib/screens/flashcards/flashcard_sets_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/flashcard_set_dbLayer.dart';
import '../../basic_classes/flashcard_set.dart';

import 'flashcard_view_screen.dart';
import 'create_flashcard_set_screen.dart';
import 'edit_flashcard_set_screen.dart'; // Import the new edit screen

class FlashcardSetsScreen extends StatelessWidget {
  const FlashcardSetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDB = Provider.of<UserDBLayer>(context);
    final setDB = Provider.of<FlashcardSetDBLayer>(context);

    final loggedInUserId = userDB.currentUser?.userId;
    if (loggedInUserId == null) {
      return const Center(child: Text('Error: Please log in.'));
    }

    // Get ALL flashcard sets, not just the user's own
    final List<FlashcardSet> allSets = setDB.sets;

    return Scaffold(
      body: allSets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No flashcard sets have been created yet. Tap + to be the first!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withOpacity(0.6),
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: allSets.length,
              itemBuilder: (context, index) {
                final flashcardSet = allSets[index];

                // Look up the creator's name for display
                final creator = userDB.getDataById(flashcardSet.createdBy);
                final creatorName = creator?.name ?? 'Unknown User';

                // Check if the current user is the owner of this set
                final bool isOwner = flashcardSet.createdBy == loggedInUserId;

                return Stack(
                  // Use a Stack to overlay the buttons
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(
                            16,
                            12,
                            48,
                            12,
                          ), // Leave space for buttons
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: const Icon(Icons.style_outlined),
                          ),
                          title: Text(
                            flashcardSet.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flashcardSet.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Created by: $creatorName',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FlashcardViewScreen(
                                  setId: flashcardSet.setId,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Conditionally display Edit/Delete buttons
                    Visibility(
                      visible: isOwner,
                      child: Positioned(
                        top: 0,
                        right: 8,
                        child: Card(
                          elevation: 4,
                          shape: const StadiumBorder(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // EDIT BUTTON
                              SizedBox(
                                height: 32,
                                width: 40,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blueGrey,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditFlashcardSetScreen(
                                              flashcardSet: flashcardSet,
                                            ),
                                      ),
                                    );
                                  },
                                  tooltip: 'Edit Set',
                                ),
                              ),
                              // DELETE BUTTON
                              SizedBox(
                                height: 32,
                                width: 40,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) =>
                                          AlertDialog(
                                            title: const Text(
                                              'Confirm Deletion',
                                            ),
                                            content: Text(
                                              'Are you sure you want to delete the set "${flashcardSet.title}"? This will also delete all the cards within it and cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed: () => Navigator.of(
                                                  dialogContext,
                                                ).pop(),
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  'DELETE',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setDB.deleteSetAndCards(
                                                    flashcardSet.setId,
                                                  );
                                                  Navigator.of(
                                                    dialogContext,
                                                  ).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                  tooltip: 'Delete Set',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateFlashcardSetScreen(),
            ),
          );
        },
        tooltip: 'Create New Flashcard Set',
        child: const Icon(Icons.add),
      ),
    );
  }
}
