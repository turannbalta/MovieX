import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../main.dart';

class MoviePageScreen extends StatefulWidget {
  final Movie movie;

  const MoviePageScreen({super.key, required this.movie});

  @override
  State<MoviePageScreen> createState() => _MoviePageScreenState();
}

class _MoviePageScreenState extends State<MoviePageScreen> {
  bool isFavourite = false;
  bool isInWatchlist = false;
  List<String> cast = [];
  List<String> genres = [];
  bool isLoadingCast = true; // Cast yükleniyor mu?
  bool isLoadingGenres = true; // Genres yükleniyor mu?

  @override
  void initState() {
    super.initState();
    isFavourite = GlobalState.isFavourite(widget.movie);
    isInWatchlist = GlobalState.isInWatchlist(widget.movie);
    _fetchGenres(); // Kategorileri çek
    _fetchCast(); // Oyuncu bilgilerini çek
  }

  Future<void> _fetchGenres() async {
    try {
      final fetchedGenres =
          await ApiService.fetchMovieGenres(widget.movie.genreIds);
      setState(() {
        genres = fetchedGenres;
        isLoadingGenres = false;
      });
    } catch (e) {
      setState(() {
        isLoadingGenres = false;
      });
      print('Error fetching genres: $e');
    }
  }

  Future<void> _fetchCast() async {
    try {
      final fetchedCast = await ApiService.fetchMovieCast(widget.movie.id);
      setState(() {
        cast = fetchedCast;
        isLoadingCast = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCast = false;
      });
      print('Error fetching cast: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      isFavourite = GlobalState.isFavourite(widget.movie);
      isInWatchlist = GlobalState.isInWatchlist(widget.movie);
    });
  }

  void _toggleFavourite() {
    setState(() {
      if (GlobalState.isFavourite(widget.movie)) {
        GlobalState.favouriteList.remove(widget.movie);
        isFavourite = false;
      } else {
        GlobalState.favouriteList.add(widget.movie);
        isFavourite = true;
      }
      GlobalState.savePreferences(); // Değişiklikleri kaydet
    });
  }

  void _toggleWatchlist() {
    setState(() {
      if (GlobalState.isInWatchlist(widget.movie)) {
        GlobalState.watchlist.remove(widget.movie);
        isInWatchlist = false;
      } else {
        GlobalState.watchlist.add(widget.movie);
        isInWatchlist = true;
      }
      GlobalState.savePreferences(); // Değişiklikleri kaydet
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.movie.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavourite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFavourite,
          ),
          IconButton(
            icon: Icon(
              isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.orange,
            ),
            onPressed: _toggleWatchlist,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Release Date
              _buildInfoRow(
                icon: Icons.calendar_today,
                title: 'Release Date',
                value: widget.movie.releaseDate,
              ),
              const SizedBox(height: 8),

              // Rated
              _buildInfoRow(
                icon: Icons.star_rate,
                title: 'Rated',
                value: '${widget.movie.rating}/10',
              ),
              const SizedBox(height: 8),

              // Overview
              const Text(
                'Overview:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.movie.overview,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),

              // Category
              const Text(
                'Category:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              isLoadingGenres
                  ? const Center(child: CircularProgressIndicator())
                  : genres.isNotEmpty
                      ? Text(
                          genres.join(' / '),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        )
                      : const Text(
                          'No genres available.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
              const SizedBox(height: 16),

              // Cast
              const Text(
                'Cast:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              isLoadingCast
                  ? const Center(child: CircularProgressIndicator())
                  : cast.isNotEmpty
                      ? Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: cast
                              .map((actor) => Chip(
                                    label: Text(
                                      actor,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                  ))
                              .toList(),
                        )
                      : const Text(
                          'No cast information available.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.orange,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '$title:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
