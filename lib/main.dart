// main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Import theme
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

// Import ALL your DBLayer classes
import 'dbLayer/book_listing_dbLayer.dart';
import 'dbLayer/book_message_dbLayer.dart';
import 'dbLayer/course_review_dbLayer.dart';
import 'dbLayer/courses_dbLayer.dart';
import 'dbLayer/flashcard_set_dbLayer.dart';
import 'dbLayer/flashcards_dbLayer.dart';
import 'dbLayer/group_members_dbLayer.dart';
import 'dbLayer/study_groups_dbLayer.dart';
import 'dbLayer/study_sessions_dbLayer.dart';
import 'dbLayer/users_dbLayer.dart';
import 'dbLayer/user_flashcard_progress_dbLayer.dart';
import 'dbLayer/test_session_dbLayer.dart';
import 'dbLayer/shared_content_db_layer.dart';
import 'dbLayer/course_material_dbLayer.dart';
import 'dbLayer/course_enrollment_dbLayer.dart';
import 'dbLayer/announcement_dbLayer.dart';
// ... and so on for all 11 DB layers

import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Create instances of all your DB layers

  final bookListingDBLayer = BookListingDBLayer();
  final bookMessageDBLayer = BookMessageDBLayer();
  final courseReviewDBLayer = CourseReviewDBLayer();
  final coursesDBLayer = CourseDBLayer();
  final flashcardSetDBLayer = FlashcardSetDBLayer();
  final flashcardDBLayer = FlashcardDBLayer();
  final groupMemberDBLayer = GroupMemberDBLayer();
  final studyGroupDBLayer = StudyGroupDBLayer();
  final studySessionDBLayer = StudySessionDBLayer();
  final userFlashcardProgressDBLayer = UserFlashcardProgressDBLayer();
  final userDBLayer = UserDBLayer();
  final testSessionDBLayer = TestSessionDBLayer();
  final sharedContentDBLayer = SharedContentDBLayer();
  final courseMaterialDBLayer = CourseMaterialDBLayer();
  final courseEnrollmentDBLayer = CourseEnrollmentDBLayer();
  final announcementDBLayer = AnnouncementDBLayer();

  // ... create instances for all others

  // IMPORTANT: Await the init() method for every single layer
  await userDBLayer.init();
  await coursesDBLayer.init();
  await courseReviewDBLayer.init();
  await bookListingDBLayer.init();
  await bookMessageDBLayer.init();
  await flashcardSetDBLayer.init();
  await flashcardDBLayer.init();
  await groupMemberDBLayer.init();
  await studyGroupDBLayer.init();
  await studySessionDBLayer.init();
  await userFlashcardProgressDBLayer.init();
  await testSessionDBLayer.init();
  await sharedContentDBLayer.init();
  await courseMaterialDBLayer.init();
  await courseEnrollmentDBLayer.init();
  await announcementDBLayer.init();
  // ... await init() for all others

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: userDBLayer),
        ChangeNotifierProvider.value(value: coursesDBLayer),
        ChangeNotifierProvider.value(value: courseReviewDBLayer),
        ChangeNotifierProvider.value(value: bookListingDBLayer),
        ChangeNotifierProvider.value(value: bookMessageDBLayer),
        ChangeNotifierProvider.value(value: flashcardSetDBLayer),
        ChangeNotifierProvider.value(value: flashcardDBLayer),
        ChangeNotifierProvider.value(value: groupMemberDBLayer),
        ChangeNotifierProvider.value(value: studyGroupDBLayer),
        ChangeNotifierProvider.value(value: studySessionDBLayer),
        ChangeNotifierProvider.value(value: userFlashcardProgressDBLayer),
        ChangeNotifierProvider.value(value: testSessionDBLayer),
        ChangeNotifierProvider.value(value: sharedContentDBLayer),
        ChangeNotifierProvider.value(value: courseMaterialDBLayer),
        ChangeNotifierProvider.value(value: courseEnrollmentDBLayer),
        ChangeNotifierProvider.value(value: announcementDBLayer),
        // ... add a provider for every single DB layer instance
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'EduConnect',
          debugShowCheckedModeBanner: false,

          // Theme configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          home: LoginScreen(),
        );
      },
    );
  }
}
