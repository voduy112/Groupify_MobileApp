import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String location;
  const MainScaffold({Key? key, required this.child, required this.location})
      : super(key: key);

  static const List<String> _titles = [
    'Trang chủ',
    'Nhóm',
    'Trò chuyện',
    'Trang cá nhân'
  ];
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
      body: child,
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade300, // màu đường viền trên
                width: 1, // độ dày viền
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_titles.length, (index) {
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () {
                  if (!isSelected) context.go(_routes[index]);
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gạch đầu
                    Container(
                      height: 4,
                      width: 24,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Color(0xFF0072ff) : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(
                      _icons[index],
                      color: isSelected ? Color(0xFF0072ff) : Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _titles[index],
                      style: TextStyle(
                        color: isSelected ? Color(0xFF0072ff) : Colors.grey,
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
