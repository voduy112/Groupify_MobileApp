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
      child: Row(
        children: [
          _buildTabButton(Icons.upload_file, 'Tài liệu', 'documents'),
          _buildTabButton(Icons.chat_bubble_outline, 'Chat nhóm', 'chat'),
          _buildTabButton(Icons.quiz_outlined, 'Bộ câu hỏi', 'quiz'),
        ],
      ),
    );
  }

  Widget _buildTabButton(IconData icon, String label, String key) {
    final isSelected = selectedTab == key;
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label),
        onPressed: () => onTabSelected(key),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromARGB(204, 22, 94, 166)
              : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: isSelected ? 6 : 0,
        ),
      ),
    );
  }
}
