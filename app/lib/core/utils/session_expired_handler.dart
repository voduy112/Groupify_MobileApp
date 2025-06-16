import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/authentication/providers/auth_provider.dart';

void handleSessionExpired(BuildContext context, String? error) {
  if (error != null &&
      error.contains("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.")) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title:
              const Text("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."),
          actions: [
            TextButton(
              onPressed: () async {
                await Provider.of<AuthProvider>(context, listen: false)
                    .logout(context);
                context.go('/login');
              },
              child: const Text("Đăng nhập lại"),
            ),
          ],
        ),
      );
    });
  }
}
