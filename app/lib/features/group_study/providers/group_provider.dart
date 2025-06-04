import 'package:flutter/material.dart';
import '../../../models/group.dart';
import '../services/group_service.dart';

class GroupProvider with ChangeNotifier {
  final GroupService _groupService = GroupService();
  Group? _selectedGroup;
  Group? get selectedGroup => _selectedGroup;
  List<Group> _groups = [];
  bool _isLoading = false;
  String? _error;

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllGroup(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _groups = await _groupService.getAllGroup(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
}
