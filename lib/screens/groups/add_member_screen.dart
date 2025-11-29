// lib/screens/groups/add_member_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import necessary DB layers and models
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/group_members_dbLayer.dart';
import '../../basic_classes/users.dart';
import '../../basic_classes/group_members.dart';

class AddMemberScreen extends StatelessWidget {
  final String groupId;

  const AddMemberScreen({
    super.key,
    required this.groupId,
  });

  // --- BACKEND CONNECTION ---
  void _addMemberToGroup(BuildContext context, Users userToAdd) {
    // Access providers with `listen: false` because this is a one-time action
    final memberDB = Provider.of<GroupMemberDBLayer>(context, listen: false);
    // ignore: unused_local_variable
    final userDB = Provider.of<UserDBLayer>(context, listen: false);

    // Create the new GroupMember object
    final newMember = GroupMember(
      memberId: '${groupId}_${userToAdd.userId}', // Composite unique ID
      userId: userToAdd.userId,
      memberNames: userToAdd.name,
      groupId: groupId,
      role: 'Member', // New members get the 'Member' role
      joinedAt: DateTime.now(),
    );

    // Add the new member to the database
    memberDB.addToHive(newMember);

    // Show a confirmation and pop the screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${userToAdd.name} has been added to the group.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // This widget needs to listen to two providers to build the list
    return Consumer2<UserDBLayer, GroupMemberDBLayer>(
      builder: (context, userDB, memberDB, child) {
        // --- DATA QUERY AND FILTERING ---

        // 1. Get a list of all user IDs who are ALREADY in the group
        final existingMemberIds = memberDB.members
            .where((member) => member.groupId == groupId)
            .map((member) => member.userId)
            .toSet(); // Use a Set for efficient lookups

        // 2. Get a list of all students who are NOT in that set of existing members
        final List<Users> availableStudents = userDB.students
            .where((student) => !existingMemberIds.contains(student.userId))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Add New Member'),
          ),
          body: availableStudents.isEmpty
              ? const Center(
                  child: Text(
                    'All available students are already in this group.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: availableStudents.length,
                  itemBuilder: (context, index) {
                    final user = availableStudents[index];
                    return ListTile(
                      leading: const Icon(Icons.person_add_alt_1),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      onTap: () {
                        // When a user is tapped, show a confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Confirm Add Member'),
                              content: Text('Are you sure you want to add ${user.name} to this group?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                ),
                                TextButton(
                                  child: const Text('Add'),
                                  onPressed: () {
                                    // Call the backend method to add the member
                                    _addMemberToGroup(context, user);
                                    // The dialog is popped by the _addMemberToGroup function
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}