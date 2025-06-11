import 'package:app/features/chat_group/services/chatgroup_service.dart';
import 'package:app/features/chat_group/views/chatgroup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/group.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../chat_group/providers/chatgroup_provider.dart';
import '../providers/group_provider.dart';
import '../services/group_service.dart';

import 'widgets/group_drawer.dart';
import 'widgets/group_header.dart';
import 'widgets/tab_buttons.dart';
import 'widgets/document_list.dart';
import 'widgets/quiz_list.dart';
import 'widgets/request_list.dart';

import '../../document/providers/document_provider.dart';
import '../../quiz/providers/quiz_provider.dart';
import '../../grouprequest/providers/grouprequest_provider.dart';
import 'widgets/member_list.dart';

class GroupDetailScreenMember extends StatefulWidget {
  final String groupId;

  const GroupDetailScreenMember({super.key, required this.groupId});

  @override
  State<GroupDetailScreenMember> createState() =>
      _GroupDetailScreenMemberState();
}

class _GroupDetailScreenMemberState extends State<GroupDetailScreenMember> {
  final GroupService _groupService = GroupService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Group? _group;
  bool _isLoading = true;
  String? _error;
  String _selectedTab = 'documents';

  List<Map<String, dynamic>> _members = [];
  bool _loadingMembers = false;
  String? _errorMembers;

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

  Future<void> _fetchGroupMembers() async {
    setState(() {
      _loadingMembers = true;
      _errorMembers = null;
    });
    try {
      final members = await _groupService.getGroupMembers(widget.groupId);
      setState(() {
        _members = members.map((e) => e.toJson()).toList();
      });
    } catch (e) {
      setState(() {
        _errorMembers = e.toString();
      });
    } finally {
      setState(() {
        _loadingMembers = false;
      });
    }
  }

  void _viewGroupMembers() async {
    Navigator.pop(context);

    await _fetchGroupMembers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: _loadingMembers
            ? const Center(child: CircularProgressIndicator())
            : _errorMembers != null
                ? Center(child: Text('Lỗi: $_errorMembers'))
                : MemberListWidget(members: _members, group: _group!),
      ),
    );
  }

  Future<void> _leaveGroup() async {
    Navigator.pop(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn rời nhóm này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rời nhóm'),
          ),
        ],
      ),
    );

    if (confirm != true || _group == null) return;

    setState(() => _isLoading = true);

    try {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).user!.id!;
      final groupId = _group!.id!;

      bool success = await Provider.of<GroupProvider>(context, listen: false)
          .leaveGroup(groupId, userId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn đã rời nhóm thành công')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rời nhóm thất bại')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rời nhóm thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteGroup() async {
    Navigator.pop(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xoá nhóm'),
        content: const Text('Bạn có chắc chắn muốn xoá nhóm này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirm != true || _group == null) return;

    final groupId = _group!.id!;
    final documentProvider =
        Provider.of<DocumentProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    try {
      // Xóa tất cả tài liệu thuộc group
      await documentProvider.deleteDocumentsByGroupId(groupId);
      // Xóa câu hỏi trong group
      await quizProvider.deleteQuizzesByGroupId(groupId);

      // Xóa group
      final success = await groupProvider.deleteGroup(groupId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xoá nhóm thành công')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xoá nhóm thất bại')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi xoá nhóm và tài nguyên: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xảy ra lỗi khi xoá nhóm')),
      );
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
          child: RequestListWidget(groupId: widget.groupId),
        ),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: _group == null
            ? null
            : GroupDrawer(
                groupId: widget.groupId,
                onViewMembers: _viewGroupMembers,
                onLeaveGroup: _leaveGroup,
                group: _group!,
                currentUserId: currentUser?.id ?? '',
                onDeleteGroup: _deleteGroup,
              ),
        body: Stack(
          children: [
            Stack(
              children: [
                GroupHeader(
                  isLoading: _isLoading,
                  error: _error,
                  group: _group,
                ),
                Positioned(
                  top: 36,
                  right: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_group != null &&
                          _group!.ownerId != null &&
                          _group!.ownerId!['_id'] == currentUser?.id)
                        IconButton(
                          icon:
                              const Icon(Icons.group_add, color: Colors.white),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: RequestListWidget(groupId: _group!.id!),
                              ),
                            );
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                      ),
                    ],
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
        return QuizList(
          scrollController: controller,
          groupId: _group?.id ?? '',
          currentUserId: currentUser?.id ?? '',
          groupOwnerId: _group?.ownerId?['_id'] ?? '',
        );
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
