import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String? userId;
  String filterStatus = 'all';
  String sortOrder = 'recent';
  bool isLoading = true;
  bool isProcessingRequest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      friendProvider = Provider.of<FriendProvider>(context, listen: false);
      ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser != null) {
        userId = currentUser.objectId;
        await friendProvider.fetchFriends();
        await friendProvider.fetchFriendRequests(userId!);
        setState(() {
          isLoading = false;
        });
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void _updateFriendsList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    friendProvider = Provider.of<FriendProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title:
              const Text('Meus Amigos', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black87,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Amigos'),
              Tab(text: 'Solicitações'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildFriendsTab(),
            buildRequestsTab(),
          ],
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
                                    labelText: "Username do Amigo"),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  final friendName = friendController.text;
                                  if (friendName.isNotEmpty && userId != null) {
                                    bool success = await friendProvider
                                        .sendFriendRequest(userId!, friendName);
                                    Navigator.pop(context);
                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text(
                                                  "Solicitação de amizade enviada!")));
                                      friendController.clear();
                                      // Voltar para a lista
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              backgroundColor: Colors.amber,
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
      ),
    );
  }

  Widget buildFriendsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await friendProvider.fetchFriends();
        _updateFriendsList();
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Pesquisar por username",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _updateFriendsList,
                ),
              ),
              onChanged: (value) {
                _updateFriendsList();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: filterStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todos')),
                      DropdownMenuItem(
                          value: 'pending', child: Text('Pendentes')),
                      DropdownMenuItem(
                          value: 'accepted', child: Text('Aceitos')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        filterStatus = value!;
                        _updateFriendsList();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: sortOrder,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                          value: 'recent', child: Text('Mais Recentes')),
                      DropdownMenuItem(
                          value: 'oldest', child: Text('Mais Antigos')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        sortOrder = value!;
                        _updateFriendsList();
                      });
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : friendProvider.friends.isEmpty
                      ? const Center(
                          child: Text("Nenhum amigo adicionado ainda."))
                      : ListView.builder(
                          itemCount: friendProvider.friends.length,
                          itemBuilder: (context, index) {
                            List friends = List.from(friendProvider.friends);

                            if (sortOrder == 'recent') {
                              friends.sort((a, b) =>
                                  b['createdAt'].compareTo(a['createdAt']));
                            } else if (sortOrder == 'oldest') {
                              friends.sort((a, b) =>
                                  a['createdAt'].compareTo(b['createdAt']));
                            }

                            final friend = friends[index];
                            final friendName = friend['name'];
                            final status = friend['type'];
                            final friendId = friend['id'];

                            if (filterStatus != 'all' &&
                                status != filterStatus) {
                              return Container();
                            }

                            if (searchController.text.isNotEmpty &&
                                !friendName.toLowerCase().contains(
                                    searchController.text.toLowerCase())) {
                              return Container();
                            }

                            return ListTile(
                              title: Text(friendName ?? "Desconhecido"),
                              subtitle: friend['createdAt'] != null
                                  ? Text(
                                      "Adicionado em: ${friend['createdAt']}")
                                  : null,
                              leading: Icon(status == "invite_sent"
                                  ? Icons.email
                                  : status == "invite_received"
                                      ? Icons.email
                                      : Icons.person_add),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        if (userId != null) {
          await friendProvider.fetchFriendRequests(userId!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : friendProvider.requests.isEmpty
                      ? const Center(
                          child: Text("Nenhuma solicitação de amizade."))
                      : ListView.builder(
                          itemCount: friendProvider.requests.length,
                          itemBuilder: (context, index) {
                            final request = friendProvider.requests[index];
                            final requestType = request['type'];
                            final requestId = request['id'];
                            final requestName = request['name'];

                            return ListTile(
                              title: Text(requestName ?? "Desconhecido"),
                              subtitle: Text(requestType == "sent"
                                  ? "Solicitação enviada"
                                  : "Solicitação recebida"),
                              leading: Icon(requestType == "sent"
                                  ? Icons.send
                                  : Icons.inbox),
                              trailing: requestType == "received"
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check,
                                              color: Colors.green),
                                          onPressed: () async {
                                            setState(() {
                                              isProcessingRequest = true;
                                            });
                                            bool success = await friendProvider
                                                .acceptFriendRequest(requestId);
                                            setState(() {
                                              isProcessingRequest = false;
                                            });
                                            if (success) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      backgroundColor:
                                                          Colors.green,
                                                      content: Text(
                                                          "Solicitação de amizade aceita!")));
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      backgroundColor:
                                                          Colors.amber,
                                                      content: Text(
                                                          "Erro ao aceitar solicitação.")));
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () async {
                                            setState(() {
                                              isProcessingRequest = true;
                                            });
                                            bool success = await friendProvider
                                                .declineFriendRequest(
                                                    requestId);
                                            setState(() {
                                              isProcessingRequest = false;
                                            });
                                            if (success) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      backgroundColor:
                                                          Colors.green,
                                                      content: Text(
                                                          "Solicitação de amizade recusada!")));
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      backgroundColor:
                                                          Colors.amber,
                                                      content: Text(
                                                          "Erro ao recusar solicitação.")));
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  : null,
                            );
                          },
                        ),
            ),
            if (isProcessingRequest)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
