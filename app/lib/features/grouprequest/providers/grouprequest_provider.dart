import 'package:flutter/material.dart';
import '../../../models/grouprequest.dart';
import '../services/grouprequest_service.dart';

class GroupRequestProvider extends ChangeNotifier {
  final GroupRequestService _service = GroupRequestService();
  List<Grouprequest> _requests = [];
  bool _isLoading = false;

  List<Grouprequest> get requests => _requests;
  bool get isLoading => _isLoading;

  Future<void> fetchRequestsByGroupId(String groupId) async {
    _isLoading = true;
    notifyListeners();

    _requests = await _service.getAllRequestsByGroupId(groupId);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendRequest(String groupId, String userId) async {
  print("Gửi yêu cầu với groupId: $groupId, userId: $userId");

  try {
    final result = await _service.createGroupRequest(groupId, userId);
    if (result != null) {
      _requests.add(result);
      notifyListeners();
      return true;
    }
    return false;
  } catch (e) {
    if (e.toString().contains("isExist")) {
      print("Yêu cầu đã tồn tại (server xác nhận)");
    } else {
      print("Lỗi gửi yêu cầu: $e");
    }
    return false;
  }
}

  Future<bool> approveRequest(String requestId) async {
    final success = await _service.approveGroupRequest(requestId);
    if (success) {
      _requests.removeWhere((req) => req.id == requestId);
      notifyListeners();
    }
    return success;
  }

  Future<bool> deleteRequest(String requestId) async {
    final success = await _service.deleteRequest(requestId);
    if (success) {
      _requests.removeWhere((req) => req.id == requestId);
      notifyListeners();
    }
    return success;
  }
}
