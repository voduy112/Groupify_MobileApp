import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/group.dart';
import '../../group_study/providers/group_provider.dart';
import 'package:provider/provider.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import '../../group_study/views/group_detail_screen.dart';

class ListGroupItem extends StatefulWidget {
  final List<Group>? groups;
  final String? from;
  const ListGroupItem({super.key, this.groups, this.from});

  @override
  State<ListGroupItem> createState() => _ListGroupItemState();
}

class _ListGroupItemState extends State<ListGroupItem> {
  @override
  Widget build(BuildContext context) {
    final groups = widget.groups ?? Provider.of<GroupProvider>(context).groups;
    if (groups.isEmpty) {
      return const Center(child: Text('Không có nhóm nào'));
    }

    print("groups: $groups");

    return Container(
      height: 400,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: groups.length + 1,
        itemBuilder: (context, index) {
          if (index == groups.length) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.go('/home/show-all-group');
                },
                child: const Text('Xem thêm'),
              ),
            );
          }

          final group = groups[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GroupDetailScreen(groupId: group.id!),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: CachedNetworkImage(
                          imageUrl: group.imgGroup ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 120,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 120,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name ?? 'Tên nhóm',
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
