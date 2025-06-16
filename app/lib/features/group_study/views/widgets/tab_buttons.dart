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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        color: const Color(0xFFF0F0F0), // Nền của khu vực Tab Buttons
        child: Row(
          children: [
            _buildTabButton(Icons.upload_file, 'Tài liệu', 'documents'),
            _buildTabButton(Icons.chat_bubble_outline, 'Trò chuyện', 'chat'),
            _buildTabButton(Icons.quiz_outlined, 'Bộ câu hỏi', 'quiz'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(IconData icon, String label, String key) {
    final isSelected = selectedTab == key;
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          size: 20,
          color: isSelected
              ? Colors.white
              : const Color.fromARGB(204, 22, 94, 166),
        ),
        label: Text(label),
        onPressed: () => onTabSelected(key),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromARGB(204, 22, 94, 166)
              : const Color(0xFFF8F8F8), // xám rất nhạt khi không chọn
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: isSelected ? 2 : 0,
          shadowColor:
              isSelected ? Colors.black.withOpacity(0.2) : Colors.transparent,
        ),
      ),
    );
  }
}
