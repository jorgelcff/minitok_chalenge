import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class InviteService {
  // Envia um convite para um número de telefone
  static Future<bool> sendInvitation(
      String inviterId, String inviteePhone) async {
    try {
      final query = QueryBuilder(ParseObject('Invitation'))
        ..whereEqualTo('invitee_phone', inviteePhone)
        ..whereEqualTo('status', 'pending');

      final existingInvites = await query.query();
      if (existingInvites.results != null &&
          existingInvites.results!.isNotEmpty) {
        print("Convite já enviado para esse número.");
        return false;
      }

      final invitation = ParseObject('Invitation')
        ..set('inviter', ParseObject('_User')..objectId = inviterId)
        ..set('invitee_phone', inviteePhone)
        ..set('status', 'pending');

      final response = await invitation.save();
      return response.success;
    } catch (e) {
      print("Erro ao enviar convite: $e");
      return false;
    }
  }

  // Verifica se o número de telefone já pertence a um usuário com status "accepted"
  static Future<bool> checkIfUserExists(String phone) async {
    final query = QueryBuilder(ParseUser.forQuery())
      ..whereEqualTo('phone', phone)
      ..whereEqualTo('status', 'accepted');

    final response = await query.query();
    return response.success &&
        response.results != null &&
        response.results!.isNotEmpty;
  }

  // Envia uma solicitação de amizade
  static Future<bool> sendFriendRequest(String senderId, String phone) async {
    try {
      final query = QueryBuilder(ParseUser.forQuery())
        ..whereEqualTo('phone', phone)
        ..whereEqualTo('status', 'accepted');

      final response = await query.query();
      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final receiver = response.results!.first as ParseUser;
        final friendRequest = ParseObject('Friend')
          ..set('sender', ParseObject('_User')..objectId = senderId)
          ..set('receiver', receiver)
          ..set('status', 'pending');

        final saveResponse = await friendRequest.save();
        return saveResponse.success;
      }
      return false;
    } catch (e) {
      print("Erro ao enviar solicitação de amizade: $e");
      return false;
    }
  }

  // Retorna os convites enviados pelo usuário
  static Future<List> getInvitations(String inviterId) async {
    final query = QueryBuilder(ParseObject('Invitation'))
      ..whereEqualTo('inviter', ParseObject('_User')..objectId = inviterId);

    final response = await query.query();
    return response.success && response.results != null
        ? response.results!
        : [];
  }

  /// Remove um convite (caso ainda não tenha sido aceito)
  static Future<bool> removeInvitation(String invitationId) async {
    final invitation = ParseObject('Invitation')..objectId = invitationId;
    final response = await invitation.delete();
    return response.success;
  }
}
