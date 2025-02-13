import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _homeStatsFuture;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _homeStatsFuture = authProvider.fetchHomeStats();
  }

  Future<void> _refreshHomeStats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _homeStatsFuture = authProvider.fetchHomeStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    authProvider.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Olá ${authProvider.user?.username}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black87,
              ),
              child: Text(
                'Minitok InviteApp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Gerenciar Convites'),
              onTap: () {
                Navigator.pushNamed(context, '/invite');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Amizades'),
              onTap: () {
                Navigator.pushNamed(context, '/friends');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHomeStats,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _homeStatsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildGridViewWithError();
            } else if (snapshot.hasData) {
              final stats = snapshot.data!;
              return _buildGridViewWithData(stats);
            } else {
              return _buildGridViewWithNoData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildGridViewWithData(Map<String, dynamic> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildGridItem('Total de Usuários',
                  stats['totalUsers'].toString(), Colors.blue);
            } else if (index == 1) {
              return _buildGridItem('Total de Amizades',
                  stats['totalFriendships'].toString(), Colors.green);
            } else if (index == 2) {
              return _buildGridItem('Solicitações Pendentes',
                  stats['pendingRequests'].toString(), Colors.orange);
            } else if (index == 3) {
              return _buildGridItem('Suas Amizades',
                  stats['userFriendships'].toString(), Colors.purple);
            } else if (index == 4) {
              return _buildButtonGridItem(
                  'Gerenciar Convites', Icons.person_add, '/invite');
            } else {
              return _buildButtonGridItem('Amizades', Icons.group, '/friends');
            }
          },
        );
      },
    );
  }

  Widget _buildGridViewWithError() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildGridItem(
                  'Erro ao carregar', 'Total de Usuários', Colors.blue);
            } else if (index == 1) {
              return _buildGridItem(
                  'Erro ao carregar', 'Total de Amizades', Colors.green);
            } else if (index == 2) {
              return _buildGridItem(
                  'Erro ao carregar', 'Solicitações Pendentes', Colors.orange);
            } else if (index == 3) {
              return _buildGridItem(
                  'Erro ao carregar', 'Suas Amizades', Colors.purple);
            } else if (index == 4) {
              return _buildButtonGridItem(
                  'Gerenciar Convites', Icons.person_add, '/invite');
            } else {
              return _buildButtonGridItem('Amizades', Icons.group, '/friends');
            }
          },
        );
      },
    );
  }

  Widget _buildGridViewWithNoData() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildGridItem('Nenhuma estatística disponível',
                  'Total de Usuários', Colors.blue);
            } else if (index == 1) {
              return _buildGridItem('Nenhuma estatística disponível',
                  'Total de Amizades', Colors.green);
            } else if (index == 2) {
              return _buildGridItem('Nenhuma estatística disponível',
                  'Solicitações Pendentes', Colors.orange);
            } else if (index == 3) {
              return _buildGridItem('Nenhuma estatística disponível',
                  'Suas Amizades', Colors.purple);
            } else if (index == 4) {
              return _buildButtonGridItem(
                  'Gerenciar Convites', Icons.person_add, '/invite');
            } else {
              return _buildButtonGridItem('Amizades', Icons.group, '/friends');
            }
          },
        );
      },
    );
  }

  Widget _buildGridItem(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGridItem(String title, IconData icon, String route) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        icon: Icon(icon, color: Colors.black),
        label: Text(title, style: const TextStyle(color: Colors.black)),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
