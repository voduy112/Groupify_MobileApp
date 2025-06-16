import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/image/background.jpeg',
            fit: BoxFit.cover,
          ),
        ),
        child, 
      ],
    );
  }
}
