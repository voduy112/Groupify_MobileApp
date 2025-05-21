import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/group_study/views/group_study_screen.dart';
import '../../features/chat/views/chat_screen.dart';
import '../../features/profile/views/profile_screen.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String location;
  const MainScaffold({Key? key, required this.child, required this.location})
      : super(key: key);

  static const List<String> _titles = ['Home', 'Group', 'Chat', 'Profile'];
  static const List<IconData> _icons = [
    Icons.home,
    Icons.group,
    Icons.chat,
    Icons.person
  ];
  static const List<String> _routes = ['/home', '/group', '/chat', '/profile'];

  int getSelectedIndex() {
    if (location.startsWith('/group')) return 1;
    if (location.startsWith('/chat')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndex();

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(_titles[selectedIndex]),
      // ),
      body: child,
      bottomNavigationBar: ConvexAppBar(
        items: List.generate(
          _titles.length,
          (i) => TabItem(icon: _icons[i], title: _titles[i]),
        ),
        initialActiveIndex: selectedIndex,
        onTap: (int index) {
          if (index != selectedIndex) {
            context.go(_routes[index]);
          }
        },
      ),
    );
  }
}
