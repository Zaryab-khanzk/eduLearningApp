// lib/screens/groups/group_detail_screen.dart

// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import all necessary DB layers and models using your project's folder structure
import '../../dbLayer/study_groups_dbLayer.dart';
import '../../dbLayer/study_sessions_dbLayer.dart';
import '../../dbLayer/group_members_dbLayer.dart';
import '../../dbLayer/users_dbLayer.dart';
import '../../dbLayer/shared_content_db_layer.dart';
import '../../dbLayer/flashcard_set_dbLayer.dart';
import '../../basic_classes/study_sessions.dart';
import '../../basic_classes/group_members.dart';
import '../../basic_classes/shared_content.dart';

// Import all necessary screens for navigation
import 'add_session_screen.dart';
import 'add_member_screen.dart';
import 'share_content_screen.dart';
import '../flashcards/flashcard_view_screen.dart';

// Import the new universal file service
import '../../services/file_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupDB = Provider.of<StudyGroupDBLayer>(context, listen: false);
    final group = groupDB.getDataById(widget.groupId);

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.groupName ?? 'Group Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'Sessions'),
            Tab(icon: Icon(Icons.people), text: 'Members'),
            Tab(icon: Icon(Icons.folder_shared), text: 'Shared Files'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SessionsTab(groupId: widget.groupId),
          _MembersTab(groupId: widget.groupId),
          _SharedFilesTab(groupId: widget.groupId),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddSessionScreen(groupId: widget.groupId),
            ),
          ),
          tooltip: 'Schedule Session',
          child: const Icon(Icons.add),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddMemberScreen(groupId: widget.groupId),
            ),
          ),
          tooltip: 'Add Member',
          child: const Icon(Icons.person_add),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ShareContentScreen(groupId: widget.groupId),
            ),
          ),
          tooltip: 'Share File',
          child: const Icon(Icons.upload_file),
        );
      default:
        return null;
    }
  }
}

// --- WIDGET FOR THE "SESSIONS" TAB (Full Implementation) ---
class _SessionsTab extends StatelessWidget {
  final String groupId;
  const _SessionsTab({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudySessionDBLayer>(
      builder: (context, sessionDB, child) {
        final List<StudySession> groupSessions = sessionDB.sessions
            .where((session) => session.groupId == groupId)
            .toList();
        if (groupSessions.isEmpty) {
          return const Center(
            child: Text(
              'No sessions scheduled yet.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: groupSessions.length,
          itemBuilder: (context, index) {
            final session = groupSessions[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.event_note),
                title: Text(
                  session.topic,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'On: ${session.scheduledTime.toLocal().toString().substring(0, 16)}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// --- WIDGET FOR THE "MEMBERS" TAB (Full Implementation) ---
class _MembersTab extends StatelessWidget {
  final String groupId;
  const _MembersTab({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GroupMemberDBLayer, UserDBLayer>(
      builder: (context, memberDB, userDB, child) {
        final currentUser = userDB.currentUser;
        if (currentUser == null) {
          return const Center(child: Text("Not logged in."));
        }

        final List<GroupMember> groupMembers = memberDB.members
            .where((member) => member.groupId == groupId)
            .toList();

        final myMembership = groupMembers.firstWhere(
          (m) => m.userId == currentUser.userId,
          orElse: () => GroupMember(
            memberId: '',
            userId: '',
            memberNames: '',
            groupId: '',
            role: '',
            joinedAt: DateTime.now(),
          ),
        );
        final bool amILeader = myMembership.role == 'Leader';

        if (groupMembers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'This group has no members.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: groupMembers.length,
          itemBuilder: (context, index) {
            final member = groupMembers[index];
            final user = userDB.getDataById(member.userId);
            final bool canBeRemoved =
                amILeader && member.userId != currentUser.userId;

            return Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(user?.name ?? 'Unknown User'),
                subtitle: Text(
                  member.role,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: member.role == 'Leader'
                        ? Colors.blue.shade700
                        : Colors.grey[600],
                  ),
                ),
                trailing: Visibility(
                  visible: canBeRemoved,
                  child: IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    tooltip: 'Remove Member',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text('Remove ${user?.name ?? 'Member'}?'),
                          content: const Text(
                            'Are you sure you want to remove this member from the group?',
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                            TextButton(
                              child: const Text(
                                'Remove',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                memberDB.deleteFromHive(member.memberId);
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// --- WIDGET FOR THE "SHARED FILES" TAB (Full and Corrected Implementation) ---
class _SharedFilesTab extends StatelessWidget {
  final String groupId;
  const _SharedFilesTab({super.key, required this.groupId});

  IconData _getIconForFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SharedContentDBLayer, FlashcardSetDBLayer, UserDBLayer>(
      builder: (context, sharedDB, setDB, userDB, child) {
        final List<SharedContent> groupContent = sharedDB.sharedItems
            .where((item) => item.groupId == groupId)
            .toList();

        if (groupContent.isEmpty) {
          return const Center(
            child: Text(
              'No files have been shared in this group yet.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: groupContent.length,
          itemBuilder: (context, index) {
            final sharedItem = groupContent[index];
            final sharer = userDB.getDataById(sharedItem.sharedByUserId);
            final sharerName = sharer?.name ?? 'Unknown';

            String title;
            IconData icon;
            VoidCallback? onTapAction;

            if (sharedItem.contentType == ContentType.flashcardSet) {
              final set = setDB.getDataById(sharedItem.contentId ?? '');
              title = set?.title ?? 'Deleted Flashcard Set';
              icon = Icons.style;
              onTapAction = () {
                if (sharedItem.contentId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          FlashcardViewScreen(setId: sharedItem.contentId!),
                    ),
                  );
                }
              };
            } else {
              // contentType is lectureNote
              title = sharedItem.fileName;
              icon = _getIconForFileName(sharedItem.fileName);
              onTapAction = () {
                if (sharedItem.fileData != null) {
                  // Use the universal file service, which works on both web and mobile
                  FileService.openFile(
                    sharedItem.fileData!,
                    sharedItem.fileName,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('File data is missing or corrupt.'),
                    ),
                  );
                }
              };
            }

            return Card(
              child: ListTile(
                leading: Icon(icon),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Shared by: $sharerName'),
                onTap: onTapAction,
              ),
            );
          },
        );
      },
    );
  }
}
