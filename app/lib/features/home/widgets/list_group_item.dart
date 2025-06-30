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

    // Hiển thị tối đa 4 nhóm đầu tiên
    final displayGroups = groups.length > 6 ? groups.sublist(0, 6) : groups;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4, // Điều chỉnh cho vừa mắt
      ),
      itemCount: displayGroups.length,
      itemBuilder: (context, index) {
        final group = displayGroups[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => GroupDetailScreen(groupId: group.id!),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey[300],
                      child: CachedNetworkImage(
                        imageUrl: group.imgGroup ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          group.name ?? 'Tên nhóm',
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Môn: ${group.subject ?? 'Không xác định'}',
                          style: TextStyle(
                            color: Colors.blueGrey[400],
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
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
    );
  }
}
