import 'package:app3_series_api/tv_show_grid.dart';
import 'package:app3_series_api/tv_show_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

class FavTvShowScreen extends StatefulWidget {
  const FavTvShowScreen({super.key});

  @override
  State<FavTvShowScreen> createState() => _FavTvShowScreenState();
}

class _FavTvShowScreenState extends State<FavTvShowScreen> {
  var sortByNameAsc = true;
  var sortByRatingAsc = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TvShowModel>().initialize();
    });
  }

  void handleSort(SortType sortType) {
    final tvShowModel = context.read<TvShowModel>();

    if (sortType == SortType.nameAsc) {
      tvShowModel.sortTvShows(sortType, sortByNameAsc);

      setState(() {
        sortByNameAsc = !sortByNameAsc;
      });
    } else if (sortType == SortType.ratingAsc) {
      tvShowModel.sortTvShows(sortType, sortByRatingAsc);

      setState(() {
        sortByRatingAsc = !sortByRatingAsc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tvShowModel = context.watch<TvShowModel>();
    var tvShows = tvShowModel.tvShows;

    return Consumer<TvShowModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(
            child: SizedBox(
              height: 96,
              width: 96,
              child: CircularProgressIndicator(strokeWidth: 12),
            ),
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(32),
              child: Container(
                child: Column(
                  spacing: 32,
                  children: [
                    Text(
                      'Erro: ${viewModel.errorMessage}',
                      style: TextStyle(fontSize: 24),
                    ),
                    ElevatedButton(
                      onPressed: () => viewModel.load(),
                      child: Text('Voltar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              if (viewModel.hasFavorites) ...[
                SizedBox(height: 8),

                Text(
                  '${tvShows.length} séries favoritas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ],

              SizedBox(height: 16),

              Expanded(
                child: viewModel.hasFavorites
                    ? TvShowGrid(tvShows: tvShows)
                    : Center(
                        child: Column(
                          children: [
                            SizedBox(height: 64),
                            Icon(
                              Icons.favorite,
                              size: 96,
                              color: Theme.of(context).colorScheme.primary,
                            ),

                            SizedBox(height: 32),

                            Text(
                              'Adicione suas séries favoritas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: SpeedDial(
                  icon: Icons.add,
                  activeIcon: Icons.close,
                  backgroundColor: Colors.blue,
                  children: [
                    SpeedDialChild(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.abc, size: 32), // ícone base
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Icon(
                              sortByNameAsc
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => handleSort(SortType.nameAsc),
                    ),
                    SpeedDialChild(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.star, size: 32), // ícone base
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Icon(
                              sortByRatingAsc
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => handleSort(SortType.ratingAsc),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
