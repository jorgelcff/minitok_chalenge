import 'package:flutter/material.dart';
import '../services/friend_service.dart';

class FriendProvider with ChangeNotifier {
  List _friends = [];

  List get friends => _friends;

  Future<void> fetchFriends(String userId) async {
    _friends = await FriendService.getFriends(userId);
    notifyListeners();
  }

  Future<bool> sendFriendRequest(String senderId, String receiverId) async {
    return await FriendService.sendFriendRequest(senderId, receiverId);
  }

  Future<bool> acceptFriendRequest(String requestId) async {
    return await FriendService.acceptFriendRequest(requestId);
  }

  Future<bool> declineFriendRequest(String requestId) async {
    return await FriendService.declineFriendRequest(requestId);
  }

  Future<bool> removeFriend(String friendId, String userId) async {
    return await FriendService.removeFriend(friendId, userId);
  }
}
