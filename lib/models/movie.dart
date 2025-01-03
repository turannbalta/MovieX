class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double rating;
  final String releaseDate;
  final List<int> genreIds; // Yeni alan

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.rating,
    required this.releaseDate,
    required this.genreIds, // Yeni alan
  });

  // fromJson methodu ile JSON'dan Movie nesnesi oluşturuluyor
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      rating: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? 'Unknown',
      genreIds: List<int>.from(json['genre_ids'] ?? []), // Tür kimlikleri
    );
  }

  // toJson methodu ile Movie nesnesi JSON formatına dönüştürülüyor
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'vote_average': rating,
      'release_date': releaseDate,
      'genre_ids': genreIds,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Movie && id == other.id);

  @override
  int get hashCode => id.hashCode;
}
