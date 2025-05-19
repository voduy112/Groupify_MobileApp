import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Register'),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
