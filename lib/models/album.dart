class Album {
  const Album({
    required this.id,
    required this.name,
    required this.year,
    required this.coverArt,
    required this.artist,
    required this.songCount,
    this.starred,
    this.rating,
  });

  final String id;
  final String name;
  final String artist;
  final String year;
  final String coverArt;
  final int songCount;
  final String? starred;
  final String? rating;

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json["id"] as String,
      name: json["name"] as String,
      artist: json["artist"] as String,
      year: json["year"] ?? "",
      coverArt: json["coverArt"],
      songCount: int.parse(json["songCount"]),
      starred: json["starred"],
      rating: json["userRating"],
    );
  }
}
