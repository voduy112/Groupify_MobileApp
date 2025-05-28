import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/list_group_item.dart';
import '../../group_study/providers/group_provider.dart';

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
    // Giả sử bạn có GroupProvider
    final groupProvider = Provider.of<GroupProvider>(context);
    final filteredGroups = groupProvider.groups
        .where((group) =>
            (group.name != null &&
                group.name!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())) ||
            (group.description != null &&
                group.description!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Groups'),
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
                  borderSide: const BorderSide(color: Colors.grey),
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
          ListGroupItem(
            groups: filteredGroups,
            from: 'show_all_group',
          ),
        ],
      ),
    );
  }
}
