import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/friend_provider.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() {
    return _FriendsPageState();
  }
}

class _FriendsPageState extends State<FriendsPage> {
  late FriendProvider friendProvider;
  late String userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      friendProvider = Provider.of<FriendProvider>(context, listen: false);

      // Obter o usuário autenticado
      ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser != null) {
        userId = currentUser.objectId!;
        await friendProvider
            .fetchFriends(userId); // Buscar amigos ao iniciar a página
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    friendProvider = Provider.of<FriendProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Amigos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: friendProvider.friends.isEmpty
            ? const Center(child: Text("Nenhum amigo adicionado ainda."))
            : ListView.builder(
                itemCount: friendProvider.friends.length,
                itemBuilder: (context, index) {
                  final friend = friendProvider.friends[index];
                  final phone = friend.get<String>('phone');
                  final name = friend.get<String>('name');

                  return ListTile(
                    title: Text(name ?? "Desconhecido"),
                    subtitle: Text("Telefone: $phone"),
                  );
                },
              ),
      ),
    );
  }
}
