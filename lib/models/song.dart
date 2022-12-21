import 'package:subby/utils/subsonic.dart';

class Song {
  const Song({
    required this.id,
    required this.title,
    required this.coverArt,
    required this.artist,
    this.artistId,
    required this.albumId,
    required this.album,
  });

  final String id;
  final String title;
  final String coverArt;
  final String artist;
  final String? artistId;
  final String albumId;
  final String album;

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json["id"] as String,
      title: json["title"] as String,
      artist: json["artist"] as String,
      artistId: json["artistId"],
      albumId: json["albumId"] as String,
      album: json["album"] as String,
      coverArt: json["coverArt"] as String,
    );
  }
}
