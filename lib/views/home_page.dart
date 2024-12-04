import 'package:app_jogos_new/helpers/game_helper.dart';
import 'package:app_jogos_new/views/game_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GameHelper helper = GameHelper();
  List<Game> games = [];

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

  void _deleteGame(int id) async {
    try {
      await helper.deleteGame(id);
      _loadGames(); // Atualiza a lista após excluir
    } catch (e) {
      _showErrorDialog("Erro", "Não foi possível excluir o jogo. Tente novamente.");
    }
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
                return Card(
                  child: ListTile(
                    title: Text(games[index].name ?? 'Nome não disponível'),
                    subtitle: Text(
                        games[index].publisher ?? 'Publicadora não disponível'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GamePage(game: games[index]),
                              ),
                            ).then((_) {
                              _loadGames(); // Atualiza após edição
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmation(context, games[index].id);
                          },
                        ),
                      ],
                    ),
                  ),
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
          ).then((_) {
            _loadGames(); // Atualiza após adicionar
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Excluir Jogo"),
          content: Text("Tem certeza que deseja excluir este jogo?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Excluir", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                _deleteGame(id); // Exclui o jogo
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
