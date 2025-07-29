import 'dart:convert';

import 'package:app3_series_api/tv_show_model.dart';
import 'package:http/http.dart' as http;

class TvShowService {
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
