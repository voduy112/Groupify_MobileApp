import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final String location;
  const MainScaffold({Key? key, required this.child, required this.location})
      : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  static const List<IconData> _icons = [
    Icons.home_outlined,
    Icons.group_outlined,
    Icons.chat_outlined,
    Icons.person_outline
  ];
  static const List<String> _routes = ['/home', '/group', '/chat', '/profile'];

  final ValueNotifier<bool> showBottomBar = ValueNotifier(true);
  double _lastOffset = 0;

  int getSelectedIndex() {
    if (widget.location.startsWith('/group')) return 1;
    if (widget.location.startsWith('/chat')) return 2;
    if (widget.location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndex();

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo is UserScrollNotification) {
            final direction = scrollInfo.direction;
            if (direction == ScrollDirection.reverse) {
              showBottomBar.value = false;
            } else if (direction == ScrollDirection.forward) {
              showBottomBar.value = true;
            }
          }
          return false;
        },
        child: widget.child,
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: showBottomBar,
        builder: (context, isVisible, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isVisible
                ? SafeArea(
                    key: const ValueKey('bottomBar'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(4, (index) {
                          final isSelected = index == selectedIndex;
                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                if (!isSelected) context.go(_routes[index]);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Container(
                                  //   height: 4,
                                  //   width: 24,
                                  //   decoration: BoxDecoration(
                                  //     color: isSelected
                                  //         ? const Color(0xFF0072ff)
                                  //         : Colors.transparent,
                                  //     borderRadius: BorderRadius.circular(2),
                                  //   ),
                                  // ),
                                  const SizedBox(height: 6),
                                  Container(
                                    decoration: isSelected
                                        ? BoxDecoration(
                                            color: const Color(0x220072ff),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          )
                                        : null,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Icon(
                                      _icons[index],

                                      color: isSelected
                                          ? const Color(0xFF0072ff)
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  )
                : const SizedBox.shrink(), // Không chiếm không gian
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    showBottomBar.dispose();
    super.dispose();
  }
}
