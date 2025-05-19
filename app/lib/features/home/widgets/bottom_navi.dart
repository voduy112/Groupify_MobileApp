import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConvexAppBar.badge(
      {2: '99+'},
      items: [
        TabItem(
          icon: Icons.home,
          title: 'Home',
        ),
        TabItem(
          icon: Icons.group,
          title: 'Group',
        ),
        TabItem(
          icon: Icons.chat,
          title: 'Chat',
        ),
        TabItem(
          icon: Icons.person,
          title: 'Profile',
        ),
      ],
      badgeMargin: EdgeInsets.only(bottom: 35, left: 47),
      onTap: (int i) => print('click index=$i'),
    );
  }
}
