import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class FriendService {
  // Retorna a lista de amigos do usuário
  static Future<List> getFriends(String userId) async {
    final query = QueryBuilder(ParseObject('Friend'))
      ..whereEqualTo('user', ParseObject('_User')..objectId = userId);

    final response = await query.query();
    return response.success && response.results != null
        ? response.results!
        : [];
  }

  // Envia uma solicitação de amizade
  static Future<bool> sendFriendRequest(
      String senderId, String receiverId) async {
    try {
      final friendRequest = ParseObject('FriendRequest')
        ..set('sender', ParseObject('_User')..objectId = senderId)
        ..set('receiver', ParseObject('_User')..objectId = receiverId)
        ..set('status', 'pending');

      final response = await friendRequest.save();
      return response.success;
    } catch (e) {
      print("Erro ao enviar solicitação de amizade: $e");
      return false;
    }
  }

  // Aceita uma solicitação de amizade
  static Future<bool> acceptFriendRequest(String requestId) async {
    try {
      final friendRequest = ParseObject('FriendRequest')..objectId = requestId;
      friendRequest.set('status', 'accepted');

      final response = await friendRequest.save();
      return response.success;
    } catch (e) {
      print("Erro ao aceitar solicitação de amizade: $e");
      return false;
    }
  }

  // Recusa uma solicitação de amizade
  static Future<bool> declineFriendRequest(String requestId) async {
    try {
      final friendRequest = ParseObject('FriendRequest')..objectId = requestId;
      friendRequest.set('status', 'declined');

      final response = await friendRequest.save();
      return response.success;
    } catch (e) {
      print("Erro ao recusar solicitação de amizade: $e");
      return false;
    }
  }

  static Future<bool> removeFriend(String friendId, String userId) async {
    try {
      final query = QueryBuilder(ParseObject('Friend'))
        ..whereEqualTo('objectId', friendId);

      final response = await query.query();
      if (response.success && response.results != null) {
        final friendship = response.results!.first;
        await friendship.delete();
        return true;
      }
      return false;
    } catch (e) {
      print("Erro ao remover amigo: $e");
      return false;
    }
  }
}
