import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = 'API_KEY'; // Api key gir

  // Filmleri kategoriye göre al
  static Future<List<Movie>> fetchMovies(String category) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$category?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList();
    } else {
      throw Exception('Failed to load movies: ${response.reasonPhrase}');
    }
  }

  // Bir filmin oyuncu kadrosunu al
  static Future<List<String>> fetchMovieCast(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('cast')) {
          return (data['cast'] as List)
              .map((castMember) => castMember['name'] as String)
              .take(5) // İlk 5 oyuncuyu alıyoruz
              .toList();
        } else {
          throw Exception('Cast data is missing in the response.');
        }
      } else {
        throw Exception(
            'Failed to fetch movie cast. Status Code: ${response.statusCode}, Reason: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching movie cast: $e');
    }
  }

  // Türleri al
  static Future<Map<int, String>> fetchGenres() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('genres')) {
          return Map<int, String>.fromEntries(
            (data['genres'] as List).map(
              (genre) => MapEntry(genre['id'] as int, genre['name'] as String),
            ),
          );
        } else {
          throw Exception('Genres data is missing in the response.');
        }
      } else {
        throw Exception(
            'Failed to fetch genres. Status Code: ${response.statusCode}, Reason: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching genres: $e');
    }
  }

  // Bir türdeki filmleri al
  static Future<List<Movie>> fetchMoviesByGenre(int genreId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=$genreId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movieData) => Movie.fromJson(movieData))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch movies by genre. Status Code: ${response.statusCode}, Reason: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching movies by genre: $e');
    }
  }

  // Filmleri arama
  static Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('results')) {
          final results = data['results'] as List;

          // Tüm sonuçları al, ardından yerel filtreleme uygula
          final movies = results.map((json) => Movie.fromJson(json)).toList();

          // Yerel filtreleme: query kelimesini başlıkta kontrol et
          return movies.where((movie) {
            return movie.title.toLowerCase().contains(query.toLowerCase());
          }).toList();
        } else {
          throw Exception('Results data is missing in the response.');
        }
      } else {
        throw Exception(
            'Failed to fetch movies. Status Code: ${response.statusCode}, Reason: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  // Film türlerini alın
  static Future<List<String>> fetchMovieGenres(List<int> genreIds) async {
    try {
      final genres = await fetchGenres(); // Mevcut tür listesini al
      return genreIds.map((id) => genres[id] ?? 'Unknown').toList();
    } catch (e) {
      throw Exception('Error fetching movie genres: $e');
    }
  }
}
