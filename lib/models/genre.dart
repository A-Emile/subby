class Genre {
  const Genre({
    required this.name,
    required this.songCount,
    required this.albumCount,
  });

  final String name;
  final int songCount;
  final int albumCount;

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      name: json["\$t"],
      songCount: int.parse(json["songCount"]),
      albumCount: int.parse(json["albumCount"]),
    );
  }
}
