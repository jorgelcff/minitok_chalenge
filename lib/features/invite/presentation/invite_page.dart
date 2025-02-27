import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/invite_provider.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  _InvitePageState createState() {
    return _InvitePageState();
  }
}

class _InvitePageState extends State<InvitePage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  late InviteProvider inviteProvider;
  late String userId;
  String filterStatus = 'all';
  String sortOrder = 'recent';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      inviteProvider = Provider.of<InviteProvider>(context, listen: false);

      // Obter o usuário autenticado
      ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser != null) {
        userId = currentUser.objectId!;
        await inviteProvider
            .fetchInvites(userId); // Buscar convites ao iniciar a página
        setState(() {
          isLoading = false;
        });
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void _openInviteModal() {
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
                        controller: phoneController,
                        decoration: const InputDecoration(
                            labelText: "Número de Telefone"),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (phoneController.text.length <= 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.amber,
                                content: Text(
                                    "Erro: O número de telefone deve ter mais de 8 dígitos."),
                              ),
                            );
                            return;
                          }

                          bool isUser = await inviteProvider
                              .checkIfUserExists(phoneController.text);
                          if (isUser) {
                            bool sendFriendRequest = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Usuário Encontrado"),
                                content: const Text(
                                    "Este número pertence a um usuário existente. Deseja enviar uma solicitação de amizade?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Não"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Sim"),
                                  ),
                                ],
                              ),
                            );

                            if (sendFriendRequest) {
                              bool success =
                                  await inviteProvider.sendFriendRequest(
                                      userId, phoneController.text);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                            "Solicitação de amizade enviada!")));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: Colors.amber,
                                        content: Text(
                                            "Erro ao enviar solicitação de amizade.")));
                              }
                              return;
                            }
                          }

                          bool success = await inviteProvider.sendInvite(
                              userId, phoneController.text);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.amber,
                                    content: const Text("Convite enviado!")));
                            phoneController.clear();
                            Navigator.pop(context); // Voltar para a lista
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.amber,
                                    content: Text(
                                        "Erro: Convite já enviado ou falha ao conectar.")));
                          }
                        },
                        child: const Text("Adicionar Convite"),
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
  }

  @override
  Widget build(BuildContext context) {
    inviteProvider = Provider.of<InviteProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Gerenciar Convites',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await inviteProvider.fetchInvites(userId);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Pesquisar por número",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
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
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
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
                        });
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : inviteProvider.invites.isEmpty
                        ? const Center(
                            child: Text("Nenhum convite enviado ainda."))
                        : ListView.builder(
                            itemCount: inviteProvider.invites.length,
                            itemBuilder: (context, index) {
                              List invites = List.from(inviteProvider.invites);

                              if (sortOrder == 'recent') {
                                invites.sort((a, b) =>
                                    b['createdAt'].compareTo(a['createdAt']));
                              } else if (sortOrder == 'oldest') {
                                invites.sort((a, b) =>
                                    a['createdAt'].compareTo(b['createdAt']));
                              }

                              final invite = invites[index];
                              final phone = invite.get<String>('invitee_phone');
                              final status = invite.get<String>('status');
                              final inviteId = invite.objectId!;

                              if (filterStatus != 'all' &&
                                  status != filterStatus) {
                                return Container();
                              }

                              if (searchController.text.isNotEmpty &&
                                  !phone!.contains(searchController.text)) {
                                return Container();
                              }

                              return ListTile(
                                leading: Icon(
                                  status == "accepted"
                                      ? Icons.check_circle
                                      : Icons.hourglass_empty,
                                  color: status == "accepted"
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                title: Text(phone ?? "Desconhecido"),
                                subtitle: Text("Status: $status"),
                                trailing: status == "pending"
                                    ? IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          await inviteProvider.removeInvite(
                                              inviteId, userId);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  backgroundColor: Colors.green,
                                                  content: Text(
                                                      "Convite removido!")));
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openInviteModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
