import 'package:flutter/material.dart';

class TitleApp extends StatelessWidget {
  final String title;
  final BuildContext context;

  const TitleApp({super.key, required this.title, required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
