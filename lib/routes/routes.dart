import 'package:flutter/material.dart';
import 'package:minitok_chalenge/features/auth/presentation/register_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/invite/presentation/invite_page.dart';
import '../features/friends/presentation/friends_page.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const invite = '/invite';
  static const friends = '/friends';
  static const register = '/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case invite:
        return MaterialPageRoute(builder: (_) => const InvitePage());
      case friends:
        return MaterialPageRoute(builder: (_) => FriendsPage());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      default:
        return MaterialPageRoute(builder: (_) => LoginPage());
    }
  }
}
