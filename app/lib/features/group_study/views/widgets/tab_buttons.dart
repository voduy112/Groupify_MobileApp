import 'package:flutter/material.dart';

class TabButtons extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabSelected;

  const TabButtons({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF0072ff);

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton(
              Icons.upload_file, 'Tài liệu', 'documents', primaryColor),
          _buildTabButton(
              Icons.chat_bubble_outline, 'Trò chuyện', 'chat', primaryColor),
          _buildTabButton(
              Icons.quiz_outlined, 'Bộ câu hỏi', 'quiz', primaryColor),
        ],
      ),
    );
  }

  Widget _buildTabButton(
      IconData icon, String label, String key, Color primaryColor) {
    final isSelected = selectedTab == key;

    return InkWell(
      onTap: () => onTabSelected(key),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 80 : 0, // hoặc 80, tuỳ giao diện
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
