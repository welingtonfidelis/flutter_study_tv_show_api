import 'dart:convert';

import 'package:app3_series_api/database_service.dart';
import 'package:app3_series_api/tv_show_model.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sql.dart';

class TvShowService {
  late final DatabaseService _databaseService;
  static final tableName = 'tv_shows';

  TvShowService() {
    _databaseService = DatabaseService();
  }

  Future<List<TvShow>> getAll() async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return _convertToList(maps);
  }

  Future<TvShow?> getById(int id) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id == ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _convertToList(maps)[0];
    } else {
      return null;
    }
  }

  List<TvShow> _convertToList(List<Map<String, dynamic>> maps) {
    return maps
        .map(
          (item) => TvShow(
            id: item['id'] as int,
            name: item['name'] as String? ?? 'N/A',
            webChannel: item['webChannel'] as String? ?? 'N/A',
            rating: (item['rating'] as num?)?.toDouble() ?? 0.0,
            summary: item['summary'] as String? ?? 'N/A',
            imageUrl: item['imageUrl'] as String? ?? '',
          ),
        )
        .toList();
  }

  Future<void> insert(TvShow tvShow) async {
    final db = await _databaseService.database;

    await db.insert(
      tableName,
      tvShow.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(int id) async {
    final db = await _databaseService.database;

    await db.delete(tableName, where: 'id == ?', whereArgs: [id]);
  }

  Future<bool> isFavorite(TvShow tvShow) async {
    final selectedTvShow = await getById(tvShow.id);

    return selectedTvShow != null;
  }

  // API
  Future<List<TvShow>> fetchTvShows(String query) async {
    final response = await http.get(
      Uri.parse('https://api.tvmaze.com/search/shows?q=$query'),
    );

    if (response.statusCode == 200) {
      final List<TvShow> tvShows = [];

      json.decode(response.body).forEach((item) {
        tvShows.add(TvShow.fromJson(item['show']));
      });

      return tvShows;
    } else {
      throw Exception('Falha ao carregar séries!');
    }
  }

  Future<TvShow> fetchTvShowById(int id) async {
    final response = await http.get(
      Uri.parse('https://api.tvmaze.com/shows/$id'),
    );

    if (response.statusCode == 200) {
      final TvShow tvShow;

      tvShow = TvShow.fromJson(json.decode(response.body));

      return tvShow;
    } else {
      throw Exception('Falha ao carregar série!');
    }
  }
}
