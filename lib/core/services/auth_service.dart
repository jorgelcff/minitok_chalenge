import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> registerUser(
      String phone, String username, String password) async {
    final cloudFunction = ParseCloudFunction("registerUser");
    final response = await cloudFunction.execute(parameters: {
      "username": username,
      "password": password,
      "phone": phone
    });

    if (response.success) {
      return true;
    } else {
      print("Erro: ${response.error!.message}");
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    final user = ParseUser(username, password, null);
    final response = await user.login();

    if (response.success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sessionToken', user.sessionToken!);
      return true;
    } else {
      return false;
    }
  }

  Future<ParseUser?> getCurrentUser() async {
    final user = await ParseUser.currentUser() as Future<ParseUser?>;
    return user;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('sessionToken');

    if (sessionToken != null) {
      final user = await ParseUser.getCurrentUserFromServer(sessionToken);
      return user != null;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionToken');
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      await user.logout();
    }
  }
}
