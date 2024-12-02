import 'package:app_jogos_new/helpers/game_helper.dart';
import 'package:app_jogos_new/views/game_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GameHelper helper = GameHelper();
  List<Game> games = List();

  @override
  void initState() {
    super.initState();
    _loadGames(); // Carrega os jogos ao iniciar a página
  }

  void _loadGames() async {
    List<Game> list = await helper.getAllGames();
    setState(() {
      games = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Jogos'),
      ),
      body: games.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(games[index].name ?? 'Nome não disponível'),
                  subtitle: Text(
                      games[index].publisher ?? 'Publicadora não disponível'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GamePage(game: games[index]),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GamePage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
