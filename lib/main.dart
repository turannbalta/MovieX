import 'dart:convert'; // JSON verisi ile çalışmak için gerekli kütüphane
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// GlobalState sınıfı, uygulamanın küresel durumunu yönetir ve SharedPreferences ile verileri saklar
class GlobalState {
  static final List<Movie> favouriteList = []; // Favori film listesi
  static final List<Movie> watchlist = []; // İzlenecek film listesi

  static Future<void> loadPreferences() async {
    final prefs = await SharedPreferences
        .getInstance(); // SharedPreferences örneğini alıyoruz

    // Favori filmleri yükle
    List<String>? favMovies = prefs.getStringList(
        'favouriteList'); // 'favouriteList' anahtarıyla favori filmleri getiriyoruz
    if (favMovies != null) {
      favouriteList.clear(); // Önceki listeyi temizle
      for (var movieData in favMovies) {
        favouriteList.add(Movie.fromJson(jsonDecode(
            movieData))); // JSON verisini Movie modeline dönüştürüp listeye ekliyoruz
      }
    }

    // İzlenecek filmleri yükle
    List<String>? watchMovies = prefs.getStringList(
        'watchlist'); // 'watchlist' anahtarıyla izlenecek filmleri getiriyoruz
    if (watchMovies != null) {
      watchlist.clear(); // Önceki listeyi temizle
      for (var movieData in watchMovies) {
        watchlist.add(Movie.fromJson(jsonDecode(
            movieData))); // JSON verisini Movie modeline dönüştürüp listeye ekliyoruz
      }
    }
  }

  // Preferences verilerini kaydeden metod
  static Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Favori filmleri kaydet
    List<String> favMovies =
        favouriteList.map((movie) => jsonEncode(movie.toJson())).toList();
    await prefs.setStringList('favouriteList', favMovies);

    // İzlenecek filmleri kaydet
    List<String> watchMovies =
        watchlist.map((movie) => jsonEncode(movie.toJson())).toList();
    await prefs.setStringList('watchlist', watchMovies);
  }

  // Bir filmin favori olup olmadığını kontrol eder
  static bool isFavourite(Movie movie) {
    return favouriteList.contains(movie);
  }

  // Bir filmin izlenecekler listesinde olup olmadığını kontrol eder
  static bool isInWatchlist(Movie movie) {
    return watchlist.contains(movie);
  }

  // Bir filmi favorilere ekler ya da çıkarır
  static Future<void> toggleFavourite(Movie movie) async {
    if (favouriteList.contains(movie)) {
      // Eğer film zaten favorilerdeyse
      favouriteList.remove(movie); // Favorilerden çıkar
    } else {
      favouriteList.add(movie); // Favorilere ekle
    }
    await savePreferences(); // Değişiklikleri SharedPreferences'a kaydet
  }

  // Bir filmi izlenecekler listesine ekler ya da çıkarır
  static Future<void> toggleWatchlist(Movie movie) async {
    if (watchlist.contains(movie)) {
      // Eğer film zaten izlenecekler listesinde varsa
      watchlist.remove(movie); // İzlenecekler listesinden çıkar
    } else {
      watchlist.add(movie); // İzlenecekler listesine ekle
    }
    await savePreferences(); // Değişiklikleri SharedPreferences'a kaydet
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalState
      .loadPreferences(); // Uygulama başlatıldığında verileri SharedPreferences'tan yükle
  runApp(
      MyApp()); // Uygulama başlatıldığında verileri SharedPreferences'tan yükle
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Debug banner'ını kaldırıyoruz
      theme: ThemeData.dark(), // Karanlık tema kullanıyoruz
      home: const HomeScreen(),
    );
  }
}
