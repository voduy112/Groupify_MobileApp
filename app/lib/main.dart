import 'package:app/features/chat/providers/chat_provider.dart';
import 'package:app/features/chat/services/chat_service.dart';
import 'package:app/features/home/widgets/list_document_item.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'features/authentication/services/auth_service.dart';
import 'features/authentication/providers/auth_provider.dart';
import 'services/notification/firebase_messaging_service.dart';
import 'routers/app_router.dart';
import 'features/authentication/providers/user_provider.dart';
import 'features/group_study/providers/group_provider.dart';
import 'features/document/providers/document_provider.dart';
import 'features/quiz/providers/quiz_provider.dart';
import 'core/themes/theme_app.dart';
import 'features/document_share/providers/document_share_provider.dart';
import 'services/api/dio_client.dart';
import 'features/grouprequest/providers/grouprequest_provider.dart';
import 'core/widgets/app_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessagingService.initFCM();

  runApp(
    OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AuthProvider(authService: AuthService()),
          ),
          ChangeNotifierProvider(
            create: (_) => DocumentShareProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => GroupProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => UserProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => GroupProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => ChatProvider(chatService: ChatService()),
          ),
          ChangeNotifierProvider(
              create: (_) =>
                  ChatgroupProvider(chatgroupService: ChatgroupService())),
          ChangeNotifierProvider(create: (_) => DocumentProvider()),
          ChangeNotifierProvider(create: (_) => QuizProvider()),
          ChangeNotifierProvider(create: (_) => GroupRequestProvider()),
          ChangeNotifierProvider(create: (_) => MessagingProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Groupify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
