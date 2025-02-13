import 'package:flutter/material.dart';
import '../services/friend_service.dart';

class FriendProvider with ChangeNotifier {
  List _friends = [];
  List _requests = [];

  List get friends => _friends;
  List get requests => _requests;

  Future<void> fetchFriends() async {
    _friends = await FriendService.getFriends();
    notifyListeners();
  }

  Future<void> fetchFriendRequests(String userId) async {
    final sentRequests = await FriendService.getSentFriendRequests(userId);
    final receivedRequests =
        await FriendService.getReceivedFriendRequests(userId);
    _requests = [...sentRequests, ...receivedRequests];
    notifyListeners();
  }

  Future<bool> sendFriendRequest(
      String senderId, String receiverUserName) async {
    return await FriendService.sendFriendRequest(senderId, receiverUserName);
  }

  Future<bool> acceptFriendRequest(String requestId) async {
    bool success = await FriendService.acceptFriendRequest(requestId);
    if (success) {
      await fetchFriends();
      await fetchFriendRequests(requestId);
    }
    return success;
  }

  Future<bool> declineFriendRequest(String requestId) async {
    bool success = await FriendService.declineFriendRequest(requestId);
    if (success) {
      await fetchFriendRequests(requestId);
    }
    return success;
  }

  Future<bool> removeFriend(String friendId, String userId) async {
    return await FriendService.removeFriend(friendId, userId);
  }
}
