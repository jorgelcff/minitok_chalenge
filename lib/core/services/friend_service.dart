import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class FriendService {
  // Retorna a lista de amigos do usuário
  static Future<List<Map<String, dynamic>>> getFriends() async {
    ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      print("Erro: Usuário não autenticado.");
      return [];
    }

    // Consultar a tabela Friend para obter os amigos do usuário
    final friendQuery = QueryBuilder(ParseObject("Friend"))
      ..whereEqualTo(
          "user", ParseObject("_User")..objectId = currentUser.objectId);

    final response = await friendQuery.query();

    if (response.success && response.results != null) {
      List<Map<String, dynamic>> friendsList = [];

      for (var friendObj in response.results!) {
        final friendPointer = friendObj.get<ParseObject>("friend");

        if (friendPointer == null) {
          print(
              "Erro: O campo 'friend' está vazio ou inválido para ${friendObj.objectId}");
          continue;
        }

        final friendId = friendPointer.objectId;

        // Consultar os detalhes do amigo (username, etc.)

        final userProfileQuery = QueryBuilder(ParseObject("UserProfile"))
          ..whereEqualTo("user", ParseObject("_User")..objectId = friendId);

        final userProfileResponse = await userProfileQuery.query();

        String friendUsername = userProfileResponse.results != null &&
                userProfileResponse.results!.isNotEmpty
            ? userProfileResponse.results!.first.get<String>("username") ??
                "Desconhecido"
            : "Desconhecido";

        // Verificar se o USUÁRIO enviou o convite para o amigo
        final inviteSentQuery = QueryBuilder(ParseObject("Invitation"))
          ..whereEqualTo("inviter", currentUser);

        final inviteSentResponse = await inviteSentQuery.query();

        // Verificar se o AMIGO enviou o convite para o USUÁRIO
        final inviteReceivedQuery = QueryBuilder(ParseObject("Invitation"))
          ..whereEqualTo("invitee", currentUser);

        final inviteReceivedResponse = await inviteReceivedQuery.query();
        String friendshipType = "unknown";
        if (inviteSentResponse.results != null &&
            inviteSentResponse.results!.isNotEmpty) {
          friendshipType = "invite_sent";
        } else if (inviteReceivedResponse.results != null &&
            inviteReceivedResponse.results!.isNotEmpty) {
          friendshipType = "invite_received";
        } else {
          // Verificar se existe uma solicitação de amizade na tabela FriendRequest
          final friendRequestQuery = QueryBuilder(ParseObject("FriendRequest"))
            ..whereEqualTo("sender", friendPointer)
            ..whereEqualTo("receiver", currentUser)
            ..whereEqualTo("status", "accepted");

          final friendRequestResponse = await friendRequestQuery.query();

          if (friendRequestResponse.results != null &&
              friendRequestResponse.results!.isNotEmpty) {
            friendshipType = "solicitation";
          }
        }

        String formattedDate = "Desconhecido";
        if (friendObj.createdAt != null) {
          final createdAt = friendObj.createdAt!;
          formattedDate =
              "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year} - ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}";
        }

        // Adicionar o amigo à lista
        friendsList.add({
          "id": friendId,
          "name": friendUsername,
          "type": friendshipType,
          "createdAt": formattedDate,
        });
      }

      return friendsList;
    } else {
      print("Erro ao buscar amigos: ${response.error?.message}");
      return [];
    }
  }

  // Função para pegar o username de um usuário
  static Future<String> _getUserUsername(ParseObject user) async {
    final userDetailsQuery = QueryBuilder(ParseObject("UserProfile"))
      ..whereEqualTo('user', ParseObject("_User")..objectId = user.objectId);

    final userDetailsResponse = await userDetailsQuery.query();
    if (userDetailsResponse.success &&
        userDetailsResponse.results != null &&
        userDetailsResponse.results!.isNotEmpty) {
      final userDetails = userDetailsResponse.results!.first;
      return userDetails.get<String>("username") ?? "Desconhecido";
    }

    return "Desconhecido";
  }

  // Envia uma solicitação de amizade
  static Future<bool> sendFriendRequestOld(
      String senderId, String friendUsername) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        print("Usuário não autenticado!");
        return false;
      }
      final query = QueryBuilder<ParseObject>(ParseObject('UserProfile'))
        ..whereEqualTo('username', friendUsername);
      final userResult = await query.query();

      if (userResult.success &&
          userResult.results != null &&
          userResult.results!.isNotEmpty) {
        final userId = userResult.results!.first['user'].objectId;
        // Criação da solicitação de amizade
        final friendRequest = ParseObject('FriendRequest')
          ..set('sender', ParseObject('_User')..objectId = senderId)
          ..set('receiver', ParseObject('_User')..objectId = userId)
          ..set('status', 'pending');

        final acl = ParseACL()
          ..setReadAccess(userId: senderId)
          ..setWriteAccess(userId: senderId)
          ..setReadAccess(userId: userId)
          ..setWriteAccess(userId: userId);

        friendRequest.setACL(acl);

        final response = await friendRequest.save();
        if (response.success) {
          print("Solicitação de amizade enviada com sucesso.");
        } else {
          print(
              "Erro ao enviar solicitação de amizade: ${response.error?.message}");
        }
        return response.success;
      } else {
        print("Erro: Usuário com o nome $friendUsername não encontrado.");
        return false;
      }
    } catch (e) {
      print("Erro ao enviar solicitação de amizade: $e");
      return false;
    }
  }

  static Future<bool> sendFriendRequest(
      String senderId, String friendUsername) async {
    try {
      final ParseCloudFunction function =
          ParseCloudFunction('sendFriendRequest');
      final ParseResponse response = await function.execute(parameters: {
        'senderId': senderId,
        'friendUsername': friendUsername,
      });

      if (response.success && response.result != null) {
        print(response.result['message']);
        return true;
      } else {
        print("Erro ao enviar solicitação: ${response.error?.message}");
        return false;
      }
    } catch (e) {
      print("Erro ao chamar a Cloud Function: $e");
      return false;
    }
  }

  // Aceita uma solicitação de amizade
  static Future<bool> acceptFriendRequest(String requestId) async {
    try {
      final friendRequestQuery =
          QueryBuilder<ParseObject>(ParseObject('FriendRequest'))
            ..whereEqualTo('objectId', requestId)
            ..whereEqualTo('status', 'pending');
      final friendRequestResponse = await friendRequestQuery.query();

      if (friendRequestResponse.success &&
          friendRequestResponse.results != null &&
          friendRequestResponse.results!.isNotEmpty) {
        final friendRequest = friendRequestResponse.results!.first;
        friendRequest.set('status', 'accepted');

        final response = await friendRequest.save();

        if (response.success) {
          final sender = friendRequest.get<ParseObject>('sender');
          final receiver = friendRequest.get<ParseObject>('receiver');

          // Criação de uma nova entrada na tabela Friend
          final friend1 = ParseObject('Friend')
            ..set('user', sender)
            ..set('friend', receiver);

          final friend2 = ParseObject('Friend')
            ..set('user', receiver)
            ..set('friend', sender);

          final acl = ParseACL()
            ..setReadAccess(userId: sender.objectId)
            ..setWriteAccess(userId: sender.objectId)
            ..setReadAccess(userId: receiver.objectId)
            ..setWriteAccess(userId: receiver.objectId);

          friend1.setACL(acl);
          friend2.setACL(acl);

          await friend1.save();
          await friend2.save();
        }
        return response.success;
      } else {
        print("Erro: Solicitação de amizade não encontrada ou já aceita.");
        return false;
      }
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

  // Retorna as solicitações de amizade enviadas pelo usuário
  static Future<List<Map<String, dynamic>>> getSentFriendRequests(
      String userId) async {
    final query = QueryBuilder<ParseObject>(ParseObject('FriendRequest'))
      ..whereEqualTo('sender', ParseObject('_User')..objectId = userId)
      ..whereEqualTo('status', 'pending');

    final response = await query.query();
    if (response.success && response.results != null) {
      List<Map<String, dynamic>> sentRequests = [];
      for (var request in response.results!) {
        final receiver = request.get<ParseObject>('receiver');
        final receiverUsername = await _getUserUsername(receiver!);
        sentRequests.add({
          'id': request.objectId,
          'name': receiverUsername,
          'type': 'sent',
        });
      }
      return sentRequests;
    } else {
      print(
          "Erro ao buscar solicitações de amizade enviadas: ${response.error?.message}");
      return [];
    }
  }

  // Retorna as solicitações de amizade recebidas pelo usuário
  static Future<List<Map<String, dynamic>>> getReceivedFriendRequests(
      String userId) async {
    final query = QueryBuilder<ParseObject>(ParseObject('FriendRequest'))
      ..whereEqualTo('receiver', ParseObject('_User')..objectId = userId)
      ..whereEqualTo('status', 'pending');

    final response = await query.query();
    if (response.success && response.results != null) {
      List<Map<String, dynamic>> receivedRequests = [];
      for (var request in response.results!) {
        final sender = request.get<ParseObject>('sender');
        final senderUsername = await _getUserUsername(sender!);
        receivedRequests.add({
          'id': request.objectId,
          'name': senderUsername,
          'type': 'received',
        });
      }
      return receivedRequests;
    } else {
      print(
          "Erro ao buscar solicitações de amizade recebidas: ${response.error?.message}");
      return [];
    }
  }
}
