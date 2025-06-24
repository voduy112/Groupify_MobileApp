import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/group.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../document/providers/document_provider.dart';
import '../../../grouprequest/providers/grouprequest_provider.dart';
import '../../../quiz/providers/quiz_provider.dart';
import '../../providers/group_provider.dart';
import '../../services/group_service.dart';
import '../../../../services/notification/messaging_provider.dart';
import '../../views/widgets/member_list.dart';

class GroupDetailController {
  final BuildContext context;
  final VoidCallback reloadUI;

  GroupDetailController(this.context, {required this.reloadUI});

  final GroupService _groupService = GroupService();
  Group? group;
  bool isLoading = true;
  String? error;
  bool isMuted = false;

  Future<void> loadGroup(String groupId) async {
    try {
      final g = await _groupService.getGroup(groupId);
      final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
      bool muted = false;
      if (currentUser != null) {
        final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
        final mutedGroups = await messagingProvider.getMutedGroups(currentUser.id!);
        muted = mutedGroups.any((group) => group['_id'] == groupId);
      }
      group = g;
      isMuted = muted;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      reloadUI();
    }
  }

  List<ChangeNotifierProvider> fetchProviders(String groupId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return [
      ChangeNotifierProvider(create: (_) => DocumentProvider(authProvider: authProvider)..fetchDocumentsByGroupId(groupId)),
      ChangeNotifierProvider(create: (_) => QuizProvider()..fetchQuizzesByGroupId(groupId)),
      ChangeNotifierProvider(create: (_) => GroupRequestProvider()..fetchRequestsByGroupId(groupId)),
    ];
  }

  Future<void> muteOrUnmuteGroup(String groupId, String userId) async {
    final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
    if (isMuted) {
      await messagingProvider.unmuteGroup(groupId, userId);
    } else {
      await messagingProvider.muteGroup(groupId, userId);
    }
    isMuted = !isMuted;
    reloadUI();
  }

  Future<void> viewGroupMembers(String groupId) async {
    Navigator.pop(context);
    try {
      final members = await _groupService.getGroupMembers(groupId);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: MemberListWidget(members: members.map((e) => e.toJson()).toList(), group: group!),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tải thành viên: $e')));
    }
  }

  Future<void> leaveGroup(String groupId) async {
    Navigator.pop(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn rời nhóm này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Rời nhóm')),
        ],
      ),
    );
    if (confirm != true || group == null) return;

    final userId = Provider.of<AuthProvider>(context, listen: false).user!.id!;
    final success = await Provider.of<GroupProvider>(context, listen: false).leaveGroup(groupId, userId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bạn đã rời nhóm thành công')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rời nhóm thất bại')));
    }
  }

  Future<void> deleteGroup(String groupId) async {
    Navigator.pop(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xoá nhóm'),
        content: const Text('Bạn có chắc chắn muốn xoá nhóm này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xoá')),
        ],
      ),
    );
    if (confirm != true || group == null) return;

    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    try {
      await documentProvider.deleteDocumentsByGroupId(groupId);
      await quizProvider.deleteQuizzesByGroupId(groupId);
      final success = await groupProvider.deleteGroup(groupId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xoá nhóm thành công')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xoá nhóm thất bại')));
      }
    } catch (e) {
      debugPrint('Lỗi xoá nhóm: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xảy ra lỗi khi xoá nhóm')));
    }
  }

  Future<bool> changeOwner(String groupId, String newOwnerId) async {
    try {
      await Provider.of<GroupProvider>(context, listen: false).changeOwnerId(groupId, newOwnerId);
      await loadGroup(groupId);
      return true;
    } catch (e) {
      debugPrint('Lỗi chuyển quyền: $e');
      return false;
    }
  }
}
