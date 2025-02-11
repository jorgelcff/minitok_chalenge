import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  ParseUser? _user;
  List<String> invites = [];
  List<String> friends = [];
  final AuthService _authService = AuthService();

  ParseUser? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String username, String password) async {
    return await _authService.login(username, password);
  }

  Future<bool> register(String phone, String username, String password) async {
    return await _authService.registerUser(phone, username, password);
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void addInvite(String phone) {
    invites.add(phone);
    notifyListeners();
  }

  void removeInvite(String phone) {
    invites.remove(phone);
    notifyListeners();
  }

  void addFriend(String friend) {
    friends.add(friend);
    notifyListeners();
  }

  void removeFriend(String friend) {
    friends.remove(friend);
    notifyListeners();
  }

  Future<ParseUser?> getCurrentUser() async {
    _user = await _authService.getCurrentUser();
    notifyListeners();
  }
}
