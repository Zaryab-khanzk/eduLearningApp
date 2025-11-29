// lib/screens/groups/create_join_group_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import all necessary DB layers and models
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/study_groups_dbLayer.dart';
import '../../dbLayer/group_members_dbLayer.dart';
import '../../basic_classes/study_groups.dart';
import '../../basic_classes/group_members.dart';
import '../../basic_classes/users.dart';

// This screen now needs to be stateful to manage the TabController
class CreateJoinGroupScreen extends StatefulWidget {
  const CreateJoinGroupScreen({super.key});

  @override
  _CreateJoinGroupScreenState createState() => _CreateJoinGroupScreenState();
}

class _CreateJoinGroupScreenState extends State<CreateJoinGroupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle), text: 'Create Group'),
            Tab(icon: Icon(Icons.search), text: 'Discover Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // The two tabs are now separate widgets for cleaner code
          _CreateGroupTab(),
          _DiscoverGroupsTab(),
        ],
      ),
    );
  }
}

// --- WIDGET FOR THE "CREATE GROUP" TAB ---
// This contains the form you previously built.
class _CreateGroupTab extends StatefulWidget {
  const _CreateGroupTab();

  @override
  __CreateGroupTabState createState() => __CreateGroupTabState();
}

class __CreateGroupTabState extends State<_CreateGroupTab> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userDB = Provider.of<UserDBLayer>(context, listen: false);
    final groupDB = Provider.of<StudyGroupDBLayer>(context, listen: false);
    final memberDB = Provider.of<GroupMemberDBLayer>(context, listen: false);
    final currentUser = userDB.currentUser!;

    final newGroupId = DateTime.now().millisecondsSinceEpoch.toString();
    final newGroup = StudyGroup(
      groupId: newGroupId,
      groupName: _groupNameController.text.trim(),
      description: _descriptionController.text.trim(),
      createdBy: currentUser.userId,
      createdAt: DateTime.now(),
    );
    groupDB.addToHive(newGroup);

    final newMember = GroupMember(
      memberId: '${newGroupId}_${currentUser.userId}',
      userId: currentUser.userId,
      memberNames: currentUser.name,
      groupId: newGroupId,
      role: 'Leader',
      joinedAt: DateTime.now(),
    );
    memberDB.addToHive(newMember);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group "${newGroup.groupName}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ... (The form fields are the same as before)
          const Text(
            'Start a new collaborative group with your peers.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _groupNameController,
            decoration: const InputDecoration(
                labelText: 'Group Name', border: OutlineInputBorder()),
            validator: (v) => v!.trim().isEmpty ? 'Please enter a group name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
                labelText: 'Group Description', border: OutlineInputBorder()),
            maxLines: 4,
            validator: (v) => v!.trim().isEmpty ? 'Please enter a description' : null,
          ),
          const SizedBox(height: 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _createGroup,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Create Group'),
                ),
        ],
      ),
    );
  }
}


// --- WIDGET FOR THE "DISCOVER GROUPS" TAB ---
// This is the new group browser functionality.
class _DiscoverGroupsTab extends StatelessWidget {
  const _DiscoverGroupsTab();

  void _joinGroup(BuildContext context, StudyGroup groupToJoin, Users currentUser) {
    final memberDB = Provider.of<GroupMemberDBLayer>(context, listen: false);

    // Create a new member object for the current user
    final newMember = GroupMember(
      memberId: '${groupToJoin.groupId}_${currentUser.userId}',
      userId: currentUser.userId,
      memberNames: currentUser.name,
      groupId: groupToJoin.groupId,
      role: 'Member', // Users joining are standard members
      joinedAt: DateTime.now(),
    );
    
    // Add the new membership to the database
    memberDB.addToHive(newMember);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have successfully joined "${groupToJoin.groupName}"!'),
        backgroundColor: Colors.green,
      ),
    );
    // Pop the whole CreateJoin screen to go back to the main group list
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // This widget needs to listen to all three providers to build its list
    return Consumer3<UserDBLayer, GroupMemberDBLayer, StudyGroupDBLayer>(
      builder: (context, userDB, memberDB, groupDB, child) {
        
        final currentUser = userDB.currentUser!;

        // 1. Get the set of IDs of groups the user is ALREADY in
        final myGroupIds = memberDB.members
            .where((m) => m.userId == currentUser.userId)
            .map((m) => m.groupId)
            .toSet();

        // 2. Filter the main list of groups to find ones the user is NOT in
        final List<StudyGroup> discoverableGroups = groupDB.groups
            .where((group) => !myGroupIds.contains(group.groupId))
            .toList();
        
        if (discoverableGroups.isEmpty) {
          return const Center(
            child: Text(
              'No other groups available to join right now.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: discoverableGroups.length,
          itemBuilder: (context, index) {
            final group = discoverableGroups[index];
            // Get the number of members currently in the group
            final memberCount = memberDB.members
                .where((m) => m.groupId == group.groupId)
                .length;

            return Card(
              child: ListTile(
                title: Text(group.groupName),
                subtitle: Text('${group.description}\n$memberCount Member(s)'),
                isThreeLine: true,
                trailing: ElevatedButton(
                  child: const Text('Join'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text('Join "${group.groupName}"?'),
                        content: const Text('Do you want to join this study group?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                          TextButton(
                            child: const Text('Join'),
                            onPressed: () {
                              _joinGroup(context, group, currentUser);
                              // The dialog is popped by the _joinGroup function via the main screen pop
                            },
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
    );
  }
}