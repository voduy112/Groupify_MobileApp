import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../group_study/views/group_item.dart';
import '../../group_study/providers/group_provider.dart';
import '../../group_study/views/group_detail_screen.dart';

class ShowAllGroupScreen extends StatefulWidget {
  const ShowAllGroupScreen({super.key});

  @override
  State<ShowAllGroupScreen> createState() => _ShowAllGroupScreenState();
}

class _ShowAllGroupScreenState extends State<ShowAllGroupScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final filteredGroups = groupProvider.groups.where((group) {
      final name = group.name?.toLowerCase() ?? '';
      final description = group.description?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) ||
          description.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả nhóm'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm nhóm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: filteredGroups.isEmpty
                ? const Center(child: Text('Không tìm thấy nhóm nào'))
                : ListView.builder(
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = filteredGroups[index];
                      return GroupItem(
                        group: group,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                GroupDetailScreen(groupId: group.id!),
                          ));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
