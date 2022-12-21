import 'package:subby/models/song.dart';

class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    this.owner,
    required this.duration,
    required this.songCount,
    this.songs,
  });

  final String id;
  final String name;
  final String? owner;
  final String duration;
  final String songCount;
  final List<Song>? songs;

  factory Playlist.fromJson(Map<String, dynamic> json, {List<dynamic>? songs}) {
    return Playlist(
      id: json["id"] as String,
      name: json["name"] as String,
      owner: json["owner"],
      duration: json["duration"] as String,
      songCount: json["songCount"] as String,
      songs: songs?.map((e) => Song.fromJson(e)).toList(),
    );
  }
}
