import 'package:app_jogos_new/Enums/e_genres.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

String idColumn = "idColumn";
String nameColumn = "nameColumn";
String publisherColumn = "publisherColumn";
String genreColumn = "genreColumn";
String ratingColumn = "ratingColumn";
String gameTable = "gameTable";

class GameHelper {
  static final GameHelper _instance = GameHelper.internal();
  factory GameHelper() => _instance;
  GameHelper.internal();
  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await init();
      return _db;
    }
  }

  // Inicializa o banco de dados
  Future<Database> init() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "game_database.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int newVersion) async {
        await db.execute(
          'CREATE TABLE $gameTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $publisherColumn TEXT, $genreColumn TEXT, $ratingColumn TEXT)',
        );
      },
    );
  }

  // Função para salvar um jogo
  Future<Game> saveGame(Game game) async {
    Database dbGame = await db;
    game.id = await dbGame.insert(gameTable, game.toMap());
    return game;
  }

  // Função para atualizar um jogo
  Future<int> updateGame(Game game) async {
    Database dbGame = await db;
    return dbGame.update(
      gameTable,
      game.toMap(),
      where: 'idColumn = ?',
      whereArgs: [game.id],
    );
  }

  // Função para recuperar todos os jogos
  Future<List<Game>> getAllGames() async {
    Database dbGame = await this.db;
    List<Map> map = await dbGame.query(gameTable);
    List<Game> listGames = [];
    for (Map m in map) {
      listGames.add(Game.fromMap(m));
    }
    return listGames;
  }

  // Função para excluir um jogo
  Future<void> deleteGame(int id) async {
    final dbGame = await db; // Acesso correto ao banco de dados

    try {
      // Deleta o jogo com o ID especificado
      await dbGame.delete(
        gameTable,
        where: '$idColumn = ?', 
        whereArgs: [id], 
      );
    } catch (e) {
      print("Erro ao excluir o jogo: $e"); 
      rethrow;
    }
  }
}

class Game {
  Game();
  int id;
  String name;
  String publisher;
  Genre genre; // Usando o enum Genre
  String rating;

  // Método para converter o banco de dados para um objeto Game
  Game.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    publisher = map[publisherColumn];
    genre = Genre.values.firstWhere(
      (e) => e.toString().split('.').last == map[genreColumn],
      orElse: () => Genre.Terror, // Valor padrão
    );
    rating = map[ratingColumn];
  }

  // Método para converter o enum para string e armazenar no banco
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      publisherColumn: publisher,
      genreColumn:
          genre.toString().split('.').last, // Armazenando o nome do enum
      ratingColumn: rating,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  // Função auxiliar para obter o enum de uma string

  @override
  String toString() {
    return "Game";
  }
}
