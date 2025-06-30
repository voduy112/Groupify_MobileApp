import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import './group_item.dart';
import './group_detail_screen_member.dart';

class SearchGroupScreen extends StatefulWidget {
  const SearchGroupScreen({super.key});

  @override
  State<SearchGroupScreen> createState() => _SearchGroupScreenState();
}

class _SearchGroupScreenState extends State<SearchGroupScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final filteredGroups = groupProvider.groups
        .where(
            (group) => group.name!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0072ff), Color.fromARGB(255, 92, 184, 241)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: TextField(
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: filteredGroups.isEmpty
          ? const Center(child: Text('Không tìm thấy nhóm nào.'))
          : ListView.builder(
              itemCount: filteredGroups.length,
              itemBuilder: (context, index) {
                return GroupItem(
                  group: filteredGroups[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupDetailScreenMember(
                          groupId: filteredGroups[index].id!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
