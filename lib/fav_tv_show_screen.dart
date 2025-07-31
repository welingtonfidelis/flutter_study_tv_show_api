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

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            tvShows.isEmpty ? 'Nenhuma série favoritada' : 'Favoritas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          SizedBox(height: 16),
          Expanded(child: TvShowGrid(tvShows: tvShows)),
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
  }
}
