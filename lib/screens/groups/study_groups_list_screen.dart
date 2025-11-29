// lib/screens/groups/study_groups_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import all the necessary DB layers and models for this screen
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/group_members_dbLayer.dart';
import '../../dbLayer/study_groups_dbLayer.dart';
import '../../basic_classes/group_members.dart';
import '../../basic_classes/study_groups.dart';

// Import the screens for navigation
import 'group_detail_screen.dart';
import 'create_join_group_screen.dart';

class StudyGroupsListScreen extends StatelessWidget {
  const StudyGroupsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- BACKEND CONNECTION: Get Data ---
    final userDB = Provider.of<UserDBLayer>(context);
    final memberDB = Provider.of<GroupMemberDBLayer>(context);
    final groupDB = Provider.of<StudyGroupDBLayer>(context);

    // This is the starting point for our query: the logged-in user's ID
    final loggedInUserId = userDB.currentUser?.userId;

    // A safeguard in case there is no logged-in user
    if (loggedInUserId == null) {
      return const Center(child: Text('Error: Not logged in.'));
    }

    // --- QUERY STEP 1: Find all of the user's group memberships ---
    final List<GroupMember> myMemberships = memberDB.members
        .where((membership) => membership.userId == loggedInUserId)
        .toList();

    return Scaffold(
      // --- UI COMPONENTS ---
      body: myMemberships.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'You are not a member of any study group yet. Tap the + button to create or join one!',
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
              // The number of items is the number of groups the user is in
              itemCount: myMemberships.length,
              itemBuilder: (context, index) {
                final membership = myMemberships[index];

                // --- QUERY STEP 2: Look up the full group details using the groupId ---
                final StudyGroup? group = groupDB.getDataById(
                  membership.groupId,
                );

                // If for some reason the group data doesn't exist, show a placeholder
                if (group == null) {
                  return const Card(
                    child: ListTile(
                      title: Text('Error: Group data not found.'),
                    ),
                  );
                }

                // --- (Optional but good) QUERY STEP 3: Look up the group creator's name ---
                final creator = userDB.getDataById(group.createdBy);
                final creatorName = creator?.name ?? 'Unknown';

                // --- LIST ITEM UI ---
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.lightGreen[100],
                      child: const Icon(Icons.group_work),
                    ),
                    title: Text(
                      group.groupName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text('Created by: $creatorName'),
                    trailing: const Icon(Icons.chevron_right),

                    // --- NAVIGATION ---
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              GroupDetailScreen(groupId: group.groupId),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      floatingActionButton: userDB.currentUser?.role == 'Student'
          ? FloatingActionButton(
              // If Student, show the button
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateJoinGroupScreen(),
                  ),
                );
              },
              tooltip: 'Create or Join Group',
              child: const Icon(Icons.add),
            )
          : null, // If Teacher, hide the button
    );
  }
}
