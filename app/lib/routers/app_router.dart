import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/main_scaffold.dart';
import '../features/authentication/views/login_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/group_study/views/group_study_screen.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/chat/views/chat_list_screen.dart';
import '../features/authentication/views/register_screen.dart';
import '../features/document_share/views/upload_document_screen.dart';
import '../features/group_study/views/group_detail_screen_member.dart';
import '../features/home/widgets/document_detail.dart';
import '../features/profile/widgets/edit_profile_screen.dart';
import '../features/authentication/views/otp_verification_screen.dart';
import '../features/home/views/show_all_document_screen.dart';
import '../features/home/views/group_detail_screen.dart';
import '../features/home/views/show_all_group_screen.dart';
import '../features/profile/views/edit_document_screen.dart';

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
              path: 'group/:id',
              builder: (context, state) {
                final groupId = state.pathParameters['id']!;
                return GroupDetailScreen(
                  key: ValueKey(groupId), 
                  groupId: groupId,
                );
              },
            ),

            GoRoute(
              path: '/show-all-document',
              builder: (context, state) => ShowAllDocumentScreen(),
            ),
            GoRoute(
              path: '/show-all-group',
              builder: (context, state) => ShowAllGroupScreen(),
            ),
            GoRoute(
              path: '/upload-document',
              builder: (context, state) => UploadDocumentScreen(),
            ),
            GoRoute(
              path: 'document/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                return DocumentDetailScreen(documentId: id!);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/group',
          builder: (context, state) => GroupStudyScreen(),
          routes: [
            GoRoute(
              path: 'detail-group/:groupId',
              builder: (context, state) {
                final groupId = state.pathParameters['groupId']!;
                return GroupDetailScreenMember(groupId: groupId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => ChatListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => EditProfileScreen(),
            ),
            GoRoute(
              path: 'document/edit/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                return EditDocumentScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: '/otp-verify',
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return OTPVerificationScreen(email: email, autoResend: true);
          },
        ),
      ],
    ),
  ],
);
