// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../debug_helpers.dart';

// Import all possible screens for both roles
import '../../dbLayer/users_dbLayer.dart';
import '../courses/course_list_screen.dart';
import '../courses/teacher_course_management_screen.dart';
import '../groups/study_groups_list_screen.dart';
import '../flashcards/flashcard_sets_screen.dart';
import '../profile/profile_screen.dart';
import '../teacher/teacher_announcements_screen.dart'; // Import New Teacher Screen
import '../teacher/teacher_analytics_screen.dart'; // Import New Teacher Screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the user's role from the provider
    final userDB = Provider.of<UserDBLayer>(context);
    final userRole = userDB.currentUser?.role;

    debugPrint(
      '🏠 HomeScreen: currentUser = ${userDB.currentUser?.name}, role = "$userRole"',
    );

    // Debug: Print all users when home screen loads
    debugPrintAllUsers(userDB);

    // Define the lists that will hold the UI configuration
    List<Widget> screens;
    List<BottomNavigationBarItem> navBarItems;
    List<String> appBarTitles;

    if (userRole == 'Teacher') {
      // --- TEACHER UI CONFIGURATION ---
      appBarTitles = ['My Courses', 'Announcements', 'Analytics', 'Profile'];
      screens = const [
        TeacherCourseManagementScreen(),
        TeacherAnnouncementsScreen(),
        TeacherAnalyticsScreen(),
        ProfileScreen(),
      ];
      navBarItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library_outlined),
          activeIcon: Icon(Icons.video_library),
          label: 'My Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign_outlined),
          activeIcon: Icon(Icons.campaign),
          label: 'Announcements',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      // --- STUDENT UI CONFIGURATION (Default) ---
      appBarTitles = ['Courses', 'Study Groups', 'Flashcards', 'Profile'];
      screens = const [
        CourseListScreen(),
        StudyGroupsListScreen(),
        FlashcardSetsScreen(),
        ProfileScreen(),
      ];
      navBarItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          activeIcon: Icon(Icons.group),
          label: 'Groups',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.style_outlined),
          activeIcon: Icon(Icons.style),
          label: 'Flashcards',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    // Ensure the selected index is valid if the number of tabs changes upon role switch
    if (_selectedIndex >= navBarItems.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[_selectedIndex]),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        items: navBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType
            .fixed, // Ensures all labels are always visible
        showUnselectedLabels: true,
      ),
    );
  }
}
