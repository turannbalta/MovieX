import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../screens/movie_page_screen.dart';

// MovieList sınıfı, kategoriye göre film listesi görüntüler
class MovieList extends StatelessWidget {
  final String category;
  final String title;
  final bool isWide;

  const MovieList({
    super.key,
    required this.category,
    required this.title,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        FutureBuilder<List<Movie>>(
          // API'den veri çekme işlemi
          future: ApiService.fetchMovies(
              category), // FetchMovies metodu ile film verilerini çekiyoruz
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Veri çekilme işlemi devam ediyorsa loading gösteriyoruz
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Hata durumunda hata mesajı gösteriyoruz
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              // Veri başarıyla geldiyse, film listesi alıyoruz
              final movies = snapshot.data!;
              return SizedBox(
                height:
                    isWide ? 250 : 200, // Yükseklik genişliğe göre ayarlanır
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // Yatay kaydırma özelliği
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return GestureDetector(
                      // Film posterine tıklanabilir alan ekliyoruz
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoviePageScreen(movie: movie),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        width: isWide ? 160 : 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.error)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox(); // Veriler boşsa, hiçbir şey göstermiyoruz
          },
        ),
      ],
    );
  }
}
