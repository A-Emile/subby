import 'album.dart';

class Artist {
  const Artist({
    required this.id,
    required this.name,
    this.coverArt,
    this.albums,
    this.albumCount,
    this.biography,
    this.similarArtist,
  });

  final String id;
  final String name;
  final List<Album>? albums;
  final String? coverArt;
  final int? albumCount;
  final String? biography;
  final List<Artist>? similarArtist;

  factory Artist.fromJson(Map<String, dynamic> json, {List<Album>? albums}) {
    return Artist(
      id: json["id"] as String,
      name: json["name"] as String,
      coverArt: json["coverArt"],
      albumCount: int.tryParse(json["albumCount"]),
      albums: albums,
    );
  }
}
