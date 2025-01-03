import 'dart:convert';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalState {
  static final List<Movie> favouriteList = [];
  static final List<Movie> watchlist = [];

  static Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load favourite movies
    List<String>? favMovies = prefs.getStringList('favouriteList');
    if (favMovies != null) {
      favouriteList.clear();
      for (var movieData in favMovies) {
        favouriteList.add(Movie.fromJson(jsonDecode(movieData)));
      }
    }

    // Load watchlist movies
    List<String>? watchMovies = prefs.getStringList('watchlist');
    if (watchMovies != null) {
      watchlist.clear();
      for (var movieData in watchMovies) {
        watchlist.add(Movie.fromJson(jsonDecode(movieData)));
      }
    }
  }

  static Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Save favourite movies
    List<String> favMovies =
        favouriteList.map((movie) => jsonEncode(movie.toJson())).toList();
    await prefs.setStringList('favouriteList', favMovies);

    // Save watchlist movies
    List<String> watchMovies =
        watchlist.map((movie) => jsonEncode(movie.toJson())).toList();
    await prefs.setStringList('watchlist', watchMovies);
  }

  static bool isFavourite(Movie movie) {
    return favouriteList.contains(movie);
  }

  static bool isInWatchlist(Movie movie) {
    return watchlist.contains(movie);
  }

  static Future<void> toggleFavourite(Movie movie) async {
    if (favouriteList.contains(movie)) {
      favouriteList.remove(movie);
    } else {
      favouriteList.add(movie);
    }
    await savePreferences(); // Save changes to shared preferences
  }

  static Future<void> toggleWatchlist(Movie movie) async {
    if (watchlist.contains(movie)) {
      watchlist.remove(movie);
    } else {
      watchlist.add(movie);
    }
    await savePreferences(); // Save changes to shared preferences
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalState.loadPreferences();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
