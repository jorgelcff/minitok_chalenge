import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:minitok_chalenge/core/providers/friend_provider.dart';
import 'package:minitok_chalenge/core/providers/invite_provider.dart';
import 'package:minitok_chalenge/features/auth/presentation/login_page.dart';
import 'package:minitok_chalenge/features/home/presentation/home_page.dart';
import 'package:minitok_chalenge/routes/routes.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';
import 'core/services/parse_service.dart';
import 'core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await ParseService.initialize();

  // Testes Iniciais e pré-cadastro do usuário admin
  // var response = await Parse().healthCheck();
  // print("Back4App está funcionando? ${response.success}");

  // final provider = AuthProvider();

  // bool registerSuccess =
  //     await provider.register("admin", "admin", "+5511999999999");
  // print("Registro de usuário: $registerSuccess");

  // bool loginSuccess = await provider.login("admin", "admin");
  // print("Login de usuário: $loginSuccess");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<bool> isConnected =
      Parse().healthCheck().then((res) => res.success);

  Future<ParseUser?> getCurrentUser() async {
    var user = await ParseUser.currentUser();
    return user as ParseUser?;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InviteProvider()),
        ChangeNotifierProvider(create: (_) => FriendProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Invite App',
        theme: ThemeData.light(),
        onGenerateRoute: AppRoutes.generateRoute,
        home: FutureBuilder<ParseUser?>(
          future: getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasData && snapshot.data != null) {
              return HomePage(); // Usuário está logado, redireciona para Home
            } else {
              return LoginPage(); // Usuário não está logado, redireciona para Login
            }
          },
        ),
      ),
    );
  }
}
