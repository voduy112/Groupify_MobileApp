import 'package:flutter/material.dart';
import 'features/authentication/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'services/notification/firebase_messaging_service.dart';
import 'features/authentication/views/login_screen.dart';
import 'package:provider/provider.dart';
import 'features/authentication/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessagingService.initFCM();
  runApp(OverlaySupport.global(
      child: MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (context) => AuthProvider(authService: AuthService())),
  ], child: MyApp())));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groupify',
      home: LoginScreen(), // Màn hình chính của ứng dụng
    );
  }
}
