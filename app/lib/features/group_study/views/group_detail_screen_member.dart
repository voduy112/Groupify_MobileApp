import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/group.dart';
import '../services/group_service.dart';

import 'widgets/group_header.dart';
import 'widgets/tab_buttons.dart';
import 'widgets/document_list.dart';
import 'widgets/quiz_list.dart';

import '../../document/providers/document_provider.dart';
import '../../quiz/providers/quiz_provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              DocumentProvider()..fetchDocumentsByGroupId(widget.groupId),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider()..fetchQuizzesByGroupId(widget.groupId),
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            GroupHeader(
              isLoading: _isLoading,
              error: _error,
              group: _group,
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.70,
              minChildSize: 0.55,
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
    switch (_selectedTab) {
      case 'documents':
        return DocumentList(scrollController: controller);
      case 'quiz':
        return QuizList(scrollController: controller);
      default:
        return const Center(child: Text('Tính năng đang phát triển'));
    }
  }
}
