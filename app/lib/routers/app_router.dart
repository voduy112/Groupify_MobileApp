import 'package:go_router/go_router.dart';
import '../core/widgets/main_scaffold.dart';
import '../features/authentication/views/login_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/group_study/views/group_study_screen.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/chat/views/chat_list_screen.dart';
import '../features/authentication/views/register_screen.dart';
import '../features/document_share/views/upload_document_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child, location: state.uri.toString());
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(),
          routes: [
            GoRoute(
              path: '/home/upload-document',
              builder: (context, state) => UploadDocumentScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/group',
          builder: (context, state) => GroupStudyScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => ChatListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => ProfileScreen(),
        ),
      ],
    ),
  ],
);
