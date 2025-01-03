import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/movie.dart';
import 'movie_page_screen.dart';
import 'genre_movies_screen.dart';
import '../widgets/movie_list.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  int _currentIndex = 0;

  static final List<Movie> favouriteList = GlobalState.favouriteList;
  static final List<Movie> watchlist = GlobalState.watchlist;

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    try {
      final results = await ApiService.searchMovies(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error fetching search results: $e');
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _onTapBottomNav(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search for a movie...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _searchMovies,
              )
            : const Text(
                '🎬 MovieX',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _stopSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _startSearch,
            ),
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder<Map<int, String>>(
          future: ApiService.fetchGenres(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text('Error loading genres'));
            }

            final genres = snapshot.data!;
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const DrawerHeader(
                    child: Center(
                      child: Text(
                        'Movie Genres',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.black45,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ...genres.entries.map((entry) {
                  return ListTile(
                    leading:
                        const Icon(Icons.local_movies, color: Colors.indigo),
                    title: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GenreMoviesScreen(
                            genreId: entry.key,
                            genreName: entry.value,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            );
          },
        ),
      ),
      body: Stack(
        children: [
          if (_currentIndex == 0)
            const SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    MovieList(category: 'now_playing', title: 'Now Playing'),
                    SizedBox(height: 16),
                    MovieList(category: 'popular', title: 'Popular'),
                    SizedBox(height: 16),
                    MovieList(category: 'top_rated', title: 'Top Rated'),
                    SizedBox(height: 16),
                    MovieList(category: 'upcoming', title: 'Upcoming'),
                  ],
                ),
              ),
            )
          else if (_currentIndex == 1)
            _buildListPage('Favourites', favouriteList)
          else if (_currentIndex == 2)
            _buildListPage('Watchlist', watchlist),
          if (_searchResults.isNotEmpty) _buildSearchResultsOverlay(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          onTap: _onTapBottomNav,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favourites'),
            BottomNavigationBarItem(
                icon: Icon(Icons.watch_later), label: 'Watchlist'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black87.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final movie = _searchResults[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                    width: 50,
                    height: 75,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(movie.title,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(movie.releaseDate,
                    style: const TextStyle(color: Colors.grey)),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MoviePageScreen(movie: movie)),
                  );
                  _stopSearch();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(
      String title, Color backgroundColor, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListPage(String title, List<Movie> list) {
    return list.isEmpty
        ? Center(
            child: Text('$title is empty',
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
          )
        : ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final movie = list[index];
              return ListTile(
                leading: Image.network(
                  'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                  width: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(movie.title),
                subtitle: Text(movie.releaseDate),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MoviePageScreen(movie: movie)),
                  );
                  setState(() {});
                },
              );
            },
          );
  }
}
