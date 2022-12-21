import 'package:subby/models/album.dart';
import 'package:subby/models/artist.dart';
import 'package:subby/models/song.dart';

class SearchResults {
  const SearchResults({
    this.albums,
    this.songs,
    this.artists,
  });

  final List<Album>? albums;
  final List<Song>? songs;
  final List<Artist>? artists;

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    List<Album> albums = [];
    List<Song> songs = [];
    List<Artist> artists = [];

    if (json["album"] is Map<String, dynamic>) {
      albums.add(Album.fromJson(json["album"]));
    } else if (json["album"] != null) {
      albums =
          json["album"].map<Album>((album) => Album.fromJson(album)).toList();
    }

    if (json["song"] is Map<String, dynamic>) {
      songs.add(Song.fromJson(json["song"]));
    } else if (json["song"] != null) {
      songs = json["song"].map<Song>((song) => Song.fromJson(song)).toList();
    }

    if (json["artist"] is Map<String, dynamic>) {
      artists.add(Artist.fromJson(json["artist"]));
    } else if (json["artist"] is List<dynamic>) {
      for (var artist in json["artist"]) {
        artists.add(Artist.fromJson(artist));
      }
    }

    return SearchResults(
      albums: albums,
      artists: artists,
      songs: songs,
    );
  }
}
