import 'package:flutter/material.dart';
import '../services/invite_service.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class InviteProvider extends ChangeNotifier {
  List<ParseObject> _invites = [];
  List<ParseObject> get invites => _invites;

  Future<void> fetchInvites(String userId) async {
    _invites = (await InviteService.getInvitations(userId)).cast<ParseObject>();
    notifyListeners();
  }

  Future<bool> sendInvite(String userId, String phone) async {
    bool success = await InviteService.sendInvitation(userId, phone);
    if (success) {
      await fetchInvites(userId);
    }
    return success;
  }

  Future<void> removeInvite(String inviteId, String userId) async {
    bool success = await InviteService.removeInvitation(inviteId);
    if (success) {
      await fetchInvites(userId);
    }
  }

  Future<bool> checkIfUserExists(String phone) async {
    return await InviteService.checkIfUserExists(phone);
  }

  Future<bool> sendFriendRequest(String senderId, String phone) async {
    return await InviteService.sendFriendRequest(senderId, phone);
  }
}
