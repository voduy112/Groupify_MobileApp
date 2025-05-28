import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/group.dart';
import '../../group_study/providers/group_provider.dart';
import 'package:provider/provider.dart';
import '../../../features/authentication/providers/auth_provider.dart';

class ListGroupItem extends StatefulWidget {
  final List<Group>? groups;
  final String? from;
  const ListGroupItem({super.key, this.groups, this.from});

  @override
  State<ListGroupItem> createState() => _ListGroupItemState();
}

class _ListGroupItemState extends State<ListGroupItem> {
  @override
  void initState() {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    super.initState();
    Future.microtask(() => Provider.of<GroupProvider>(context, listen: false)
        .fetchAllGroup(userId ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups ?? Provider.of<GroupProvider>(context).groups;
    print("groups: $groups");

    return Expanded(
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return GestureDetector(
            onTap: () {
              context
                  .go('/home/group/${group.id}', extra: {'from': widget.from});
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Image.network(
                          group.imgGroup ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Thông tin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${group.name ?? 'Title group'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Môn: ${group.subject ?? 'Không xác định'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
