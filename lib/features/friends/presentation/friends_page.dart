import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/friend_provider.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController friendController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  late FriendProvider friendProvider;
  late String userId;
  String filterStatus = 'all';
  String sortOrder = 'recent';

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
      appBar: AppBar(title: const Text('Gerenciar Amigos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Pesquisar por nome",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ),
            ),
            DropdownButton<String>(
              value: filterStatus,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Todos')),
                DropdownMenuItem(value: 'pending', child: Text('Pendentes')),
                DropdownMenuItem(value: 'accepted', child: Text('Aceitos')),
              ],
              onChanged: (value) {
                setState(() {
                  filterStatus = value!;
                });
              },
            ),
            DropdownButton<String>(
              value: sortOrder,
              items: const [
                DropdownMenuItem(value: 'recent', child: Text('Mais Recentes')),
                DropdownMenuItem(value: 'oldest', child: Text('Mais Antigos')),
              ],
              onChanged: (value) {
                setState(() {
                  sortOrder = value!;
                });
              },
            ),
            Expanded(
              child: friendProvider.friends.isEmpty
                  ? const Center(child: Text("Nenhum amigo adicionado ainda."))
                  : ListView.builder(
                      itemCount: friendProvider.friends.length,
                      itemBuilder: (context, index) {
                        final friend = friendProvider.friends[index];
                        final friendName = friend.get<String>('friend_name');
                        final status = friend.get<String>('status');
                        final friendId = friend.objectId!;

                        if (filterStatus != 'all' && status != filterStatus) {
                          return Container();
                        }

                        if (searchController.text.isNotEmpty &&
                            !friendName!.contains(searchController.text)) {
                          return Container();
                        }

                        return ListTile(
                          title: Text(friendName ?? "Desconhecido"),
                          subtitle: Text("Status: $status"),
                          trailing: status == "pending"
                              ? IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await friendProvider.removeFriend(
                                        friendId, userId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text("Amigo removido!")));
                                  },
                                )
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.5,
                  maxChildSize: 1.0,
                  expand: false,
                  builder: (context, scrollController) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: friendController,
                              decoration: const InputDecoration(
                                  labelText: "Nome do Amigo"),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                final friendName = friendController.text;
                                if (friendName.isNotEmpty) {
                                  bool success = await friendProvider
                                      .sendFriendRequest(userId, friendName);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Solicitação de amizade enviada!")));
                                    friendController.clear();
                                    Navigator.pop(
                                        context); // Voltar para a lista
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Erro ao enviar solicitação de amizade.")));
                                  }
                                }
                              },
                              child: const Text("Adicionar Amigo"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
