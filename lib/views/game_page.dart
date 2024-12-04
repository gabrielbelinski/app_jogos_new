import 'package:app_jogos_new/helpers/game_helper.dart';
import 'package:app_jogos_new/views/home_page.dart';
import 'package:flutter/material.dart';

import '../Enums/e_genres.dart';

class GamePage extends StatefulWidget {
  final Game game; // O parâmetro para editar um jogo existente
  const GamePage({Key key, this.game}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  TextEditingController _nameController;
  TextEditingController _publisherController;
  TextEditingController _ratingController;
  Genre _selectedGenre = Genre.Terror; // Valor padrão do gênero

  @override
  void initState() {
    super.initState();
    // Se estiver editando um jogo, preenche os campos com os valores existentes
    if (widget.game != null) {
      _nameController = TextEditingController(text: widget.game.name);
      _publisherController = TextEditingController(text: widget.game.publisher);
      _ratingController = TextEditingController(text: widget.game.rating);
      _selectedGenre =
          widget.game.genre ?? Genre.Terror; // Define o gênero atual

    } else {
      _nameController = TextEditingController();
      _publisherController = TextEditingController();
      _ratingController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _publisherController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  // Função para salvar o jogo
  void _saveGame() async {
    if (_nameController.text.isEmpty) {
      _showAlert("Erro", "O nome do jogo é obrigatório!");
      return;
    }

    Game game = Game()
      ..name = _nameController.text
      ..publisher = _publisherController.text
      ..rating = _ratingController.text
      ..genre = _selectedGenre;

    if (widget.game != null) {
      // Se for edição, atualiza o jogo
      game.id = widget.game.id;
      await GameHelper().updateGame(game);
    } else {
      // Se for criação, salva um novo jogo
      await GameHelper().saveGame(game);
    }

    // Volta para a tela anterior após salvar
    Navigator.pop(context); // Fecha a tela atual
  }

  // Função para mostrar o alerta
  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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

  // Função para cancelar a edição
  void _cancel() {
    if (_nameController.text.isNotEmpty ||
        _publisherController.text.isNotEmpty ||
        _ratingController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Deseja sair?"),
            content: Text("Se sair, as alterações serão descartadas."),
            actions: <Widget>[
              TextButton(
                child: Text("Manter na tela"),
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha apenas o diálogo
                },
              ),
              TextButton(
                child: Text("Sair"),
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                  Navigator.of(this.context).pop(); // Sai da tela atual
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop(); // Sai da tela atual diretamente
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game == null ? 'Adicionar Jogo' : 'Editar Jogo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: _cancel, // Chama a função de cancelar
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do Jogo'),
            ),
            TextField(
              controller: _publisherController,
              decoration: const InputDecoration(labelText: 'Publicadora'),
            ),
            TextField(
              controller: _ratingController,
              decoration: const InputDecoration(labelText: 'Classificação'),
            ),
            DropdownButton<Genre>(
              value: _selectedGenre,
              onChanged: (Genre newGenre) {
                setState(() {
                  _selectedGenre = newGenre;
                });
              },
              items: Genre.values.map((Genre genre) {
                return DropdownMenuItem<Genre>(
                  value: genre,
                  child: Text(genre.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveGame(); // Salva o jogo
              },
              child: Text(widget.game == null ? 'Salvar' : 'Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
