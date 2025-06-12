import 'dart:io';

import 'package:flutter/material.dart';
import '../../../models/group.dart';
import '../../../models/user.dart';
import '../services/group_service.dart';

class GroupProvider with ChangeNotifier {
  final GroupService _groupService = GroupService();
  Group? _selectedGroup;
  Group? get selectedGroup => _selectedGroup;
  List<Group> _groups = [];
  bool _isLoading = false;
  String? _error;
  List<User> _members = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<User> get members => _members;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  Future<void> fetchAllGroup(String userId, {int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _groupService.getAllGroup(userId, page: page);
      if (page == 1) {
        _groups = response.groups;
      } else {
        _groups.addAll(response.groups);
      }
      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreGroups(String userId) async {
    if (_currentPage >= _totalPages || _isFetchingMore) return;
    _isFetchingMore = true;
    notifyListeners();
    await fetchAllGroup(userId, page: _currentPage + 1);
    _isFetchingMore = false;
    notifyListeners();
  }

  Future<void> fetchGroupsByUserId(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = await _groupService.getAllGroupbyUserId(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearGroups() {
    _groups = [];
    notifyListeners();
  }

  Future<void> fetchGroupById(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedGroup = await _groupService.getGroup(groupId);
    } catch (e) {
      _error = e.toString();
      _selectedGroup = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinGroupByCode(
      String groupId, String inviteCode, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final group =
          await _groupService.joinGroupByCode(groupId, inviteCode, userId);
      _groups.add(group);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGroup({
    required String name,
    required String description,
    required String subject,
    required String inviteCode,
    required String ownerId,
    List<String>? membersID,
    required File imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final group = await _groupService.createGroup(
        name: name,
        description: description,
        subject: subject,
        inviteCode: inviteCode,
        ownerId: ownerId,
        membersID: membersID,
        imageFile: imageFile,
      );
      _groups.add(group);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGroupMembers(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _members = await _groupService.getGroupMembers(groupId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeMember(String groupId, String memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _groupService.removeMember(groupId: groupId, memberId: memberId);

      // Optional: Nếu bạn có _selectedGroup?.members → bạn có thể remove luôn memberId khỏi đó để cập nhật UI.
      _selectedGroup?.membersID?.remove(memberId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> leaveGroup(String groupId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _groupService.leaveGroup(groupId, userId);
      await fetchGroupsByUserId(userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _groupService.deleteGroup(groupId);
      _groups.removeWhere((group) => group.id == groupId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateGroup({
    required String groupId,
    required String name,
    required String description,
    required String subject,
    List<String>? membersID,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedGroup = await _groupService.updateGroup(
        groupId: groupId,
        name: name,
        description: description,
        subject: subject,
        membersID: membersID,
        imageFile: imageFile,
      );

      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        _groups[index] = updatedGroup;
      }

      if (_selectedGroup?.id == groupId) {
        _selectedGroup = updatedGroup;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
