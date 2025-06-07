import 'package:app/features/chat_group/services/chatgroup_service.dart';
import 'package:app/features/chat_group/views/chatgroup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/group.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../authentication/providers/user_provider.dart';
import '../../chat_group/providers/chatgroup_provider.dart';
import '../services/group_service.dart';

import 'widgets/group_header.dart';
import 'widgets/tab_buttons.dart';
import 'widgets/document_list.dart';
import 'widgets/quiz_list.dart';
import 'widgets/request_list.dart';

import '../../document/providers/document_provider.dart';
import '../../quiz/providers/quiz_provider.dart';
import '../../grouprequest/providers/grouprequest_provider.dart';

class GroupDetailScreenMember extends StatefulWidget {
  final String groupId;

  const GroupDetailScreenMember({super.key, required this.groupId});

  @override
  State<GroupDetailScreenMember> createState() =>
      _GroupDetailScreenMemberState();
}

class _GroupDetailScreenMemberState extends State<GroupDetailScreenMember> {
  final GroupService _groupService = GroupService();
  Group? _group;
  bool _isLoading = true;
  String? _error;
  String _selectedTab = 'documents';

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    try {
      final group = await _groupService.getGroup(widget.groupId);
      setState(() {
        _group = group;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              DocumentProvider()..fetchDocumentsByGroupId(widget.groupId),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider()..fetchQuizzesByGroupId(widget.groupId),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatgroupProvider(chatgroupService: ChatgroupService())
            ..getGroupMessages(widget.groupId),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              GroupRequestProvider()..fetchRequestsByGroupId(widget.groupId),
          child: RequestListWidget(
            groupId: widget.groupId,
          ),
        )
      ],
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Chi tiết nhóm'),
        //   actions: [
        //     if (_group != null && _group!.ownerId == currentUser?.id)
        //       IconButton(
        //         icon: const Icon(Icons.group_add),
        //         onPressed: () {
        //           showModalBottomSheet(
        //             context: context,
        //             isScrollControlled: true,
        //             builder: (context) => SizedBox(
        //               height: MediaQuery.of(context).size.height * 0.7,
        //               child: RequestListWidget(groupId: _group!.id!),
        //             ),
        //           );
        //         },
        //       ),
        //   ],
        // ),
        body: Stack(
          children: [
            // Stack con để hiển thị ảnh và icon add
            Stack(
              children: [
                GroupHeader(
                  isLoading: _isLoading,
                  error: _error,
                  group: _group,
                ),
                if (_group != null &&
                    _group!.ownerId != null &&
                    _group!.ownerId!['_id'] == currentUser?.id)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.group_add, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: RequestListWidget(groupId: _group!.id!),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.75,
              maxChildSize: 0.96,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      TabButtons(
                        selectedTab: _selectedTab,
                        onTabSelected: (tab) {
                          setState(() => _selectedTab = tab);
                        },
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _buildTabContent(scrollController),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ScrollController controller) {
    final currentUser = Provider.of<AuthProvider>(context).user;

    switch (_selectedTab) {
      case 'documents':
        return DocumentList(
          scrollController: controller,
          groupId: _group?.id ?? '',
          currentUserId: currentUser?.id ?? '',
          groupOwnerId: _group?.ownerId?['_id'] ?? '',
        );
      case 'quiz':
        return QuizList(scrollController: controller);
      case 'chat':
        if (_group == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ChatgroupScreen(
          groupId: _group?.id ?? '',
          groupName: _group?.name ?? '',
          currentUser: currentUser!,
          scrollController: controller,
        );
      default:
        return const Center(child: Text('Tính năng đang phát triển'));
    }
  }
}
