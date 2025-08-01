import 'package:app3_series_api/tv_show_service.dart';
import 'package:flutter/material.dart';

class TvShow {
  int id;
  String imageUrl;
  String name;
  String webChannel;
  double rating;
  String summary;

  TvShow({
    required this.id,
    required this.name,
    required this.webChannel,
    required this.rating,
    required this.summary,
    required this.imageUrl,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'],
      name: json['name'],
      webChannel: json['webChannel']?['name'] ?? 'N/A',
      rating: json['rating']?['average']?.toDouble() ?? 0.0,
      summary: json['summary'] ?? 'N/A',
      imageUrl: json['image']?['medium'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'webChannel': webChannel,
      'rating': rating,
      'summary': summary,
      'imageUrl': imageUrl,
    };
  }
}

enum SortType { nameAsc, ratingAsc }

class TvShowModel extends ChangeNotifier {
  // Estado das séries favoritas
  List<TvShow> _tvShows = [];
  bool _isLoading = false;
  String? _errorMessage = '';
  List<TvShow> get tvShows => _tvShows;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasFavorites => _tvShows.isNotEmpty;

  late final TvShowService _tvShowService;

  TvShowModel() {
    _tvShowService = TvShowService();

    initialize();
  }

  Future<void> initialize() async {
    await load();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;

    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;

    notifyListeners();
  }

  Future<void> load() async {
    try {
      _setLoading(true);
      _setErrorMessage(null);
      _tvShows = await _tvShowService.getAll();
    } catch (e) {
      _setErrorMessage('Falha ao carregar séries favoritas: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToFavorites(TvShow tvShow) async {
    await _tvShowService.insert(tvShow);

    load();

    notifyListeners();
  }

  Future<void> removeFromFavorites(TvShow tvShow) async {
    await _tvShowService.delete(tvShow.id);

    load();

    notifyListeners();
  }

  Future<List<TvShow>> searchTvShows(String query) async {
    try {
      return await _tvShowService.fetchTvShows(query);
    } catch (e) {
      throw Exception('Falha na busca: ${e.toString()}');
    }
  }

  Future<TvShow> getTvShowById(int id) async {
    try {
      return await _tvShowService.fetchTvShowById(id);
    } catch (e) {
      throw Exception('Falha ao carregar: ${e.toString()}');
    }
  }

  Future<bool> isFavorite(TvShow tvShow) async {
    try {
      return await _tvShowService.isFavorite(tvShow);
    } catch (e) {
      _setErrorMessage('Falha ao checar favorito: ${e.toString()}');

      return false;
    }
  }

  void sortTvShows(SortType sortType, bool asc) {
    if (sortType == SortType.nameAsc) {
      if (asc) {
        tvShows.sort((a, b) => a.name.compareTo(b.name));
      } else {
        tvShows.sort((a, b) => b.name.compareTo(a.name));
      }
    } else if (sortType == SortType.ratingAsc) {
      if (asc) {
        tvShows.sort((a, b) => a.rating.compareTo(b.rating));
      } else {
        tvShows.sort((a, b) => b.rating.compareTo(a.rating));
      }
    }

    notifyListeners();
  }

  void editTvShow(TvShow oldTvShow, TvShow newTvShow, BuildContext context) {
    final index = tvShows.indexOf(oldTvShow);
    tvShows[index] = newTvShow;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Série ${index + 1} atualizada!'),
        duration: Duration(seconds: 2),
      ),
    );
    notifyListeners();
  }
}
