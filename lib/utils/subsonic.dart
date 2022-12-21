import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:subby/models/artist.dart';
import 'package:subby/models/genre.dart';
import 'package:subby/models/playlist.dart';
import 'package:subby/models/searchResults.dart';
import 'package:subby/models/song.dart';
import 'package:subby/utils/shared_preferences.dart';

import 'package:xml2json/xml2json.dart';
import 'package:http/http.dart' as http;

import '../models/album.dart';
import '../models/settings.dart';

const String clientName = "Subby";
String subsonicApiVersion = "1.12.0";

class SubsonicAPI {
  static final xmlTransformer = Xml2Json();

  static Uri getUri({required String path, Map<String, dynamic>? query}) {
    final Settings settings = Settings.getFromPrefs(UserSettings.prefs());
    Map<String, dynamic> q = {
      "u": settings.username,
      "p": settings.password,
      "v": subsonicApiVersion,
      "c": clientName,
    };
    if (query != null) q.addAll(query);
    Uri url = Uri.parse("${settings.server}/rest/$path");
    url = url.replace(queryParameters: q);
    return url;
  }

  static Future<List<Playlist>> getPlaylists() async {
    List<Playlist> parse(String responseBody) {
      final myTransformer = Xml2Json();

      myTransformer.parse(responseBody);
      var json = myTransformer.toGData();

      final parsed =
          jsonDecode(json)["subsonic-response"]["playlists"]["playlist"];
      final playlists = parsed
          .map<Playlist>((playlist) => Playlist.fromJson(playlist))
          .toList();

      return playlists;
    }

    Uri url = getUri(path: "getPlaylists");

    final response = await http.Client().get(url);

    return compute(parse, response.body);
  }

  static Future<String> star(String id) async {
    String parse(String responseBody) {
      try {
        xmlTransformer.parse(responseBody);
        var json = xmlTransformer.toGData();
        final parsed = jsonDecode(json)["subsonic-response"];
        final error = jsonDecode(json)["subsonic-response"]["error"];
        return error?["message"] ?? "success";
      } catch (e) {
        return e.toString();
      }
    }

    try {
      Uri url = getUri(path: "star", query: {"id": id});

      final response = await http.Client().get(url);
      return compute(parse, response.body);
    } catch (e) {
      return "Unknown error";
    }
  }

  static Future<String> unstar(String id) async {
    String parse(String responseBody) {
      try {
        xmlTransformer.parse(responseBody);
        var json = xmlTransformer.toGData();
        final parsed = jsonDecode(json)["subsonic-response"];
        final error = jsonDecode(json)["subsonic-response"]["error"];
        return error?["message"] ?? "success";
      } catch (e) {
        return e.toString();
      }
    }

    try {
      Uri url = getUri(path: "unstar", query: {"id": id});

      final response = await http.Client().get(url);
      return compute(parse, response.body);
    } catch (e) {
      return "Unknown error";
    }
  }

  static Future<String> setRating(String id, int rating) async {
    String parse(String responseBody) {
      try {
        xmlTransformer.parse(responseBody);
        var json = xmlTransformer.toGData();
        final parsed = jsonDecode(json)["subsonic-response"];
        final error = jsonDecode(json)["subsonic-response"]["error"];
        return error?["message"] ?? "success";
      } catch (e) {
        return e.toString();
      }
    }

    try {
      Uri url = getUri(
          path: "setRating", query: {"id": id, "rating": rating.toString()});

      final response = await http.Client().get(url);
      return compute(parse, response.body);
    } catch (e) {
      return "Unknown error";
    }
  }

  static Future<List<Genre>> getGenres() async {
    List<Genre> parse(String responseBody) {
      final myTransformer = Xml2Json();

      myTransformer.parse(responseBody);
      var json = myTransformer.toGData();

      final parsed = jsonDecode(json)["subsonic-response"]["genres"]["genre"];
      final List<Genre> genres =
          parsed.map<Genre>((genre) => Genre.fromJson(genre)).toList();

      return genres;
    }

    Uri url = getUri(path: "getGenres");

    final response = await http.Client().get(url);

    return compute(parse, response.body);
  }

  static Future<List<Song>> getSongsByGenre(String genre) async {
    List<Song> parse(String responseBody) {
      final myTransformer = Xml2Json();

      myTransformer.parse(responseBody);
      var json = myTransformer.toGData();

      final parsed =
          jsonDecode(json)["subsonic-response"]["songsByGenre"]["song"];
      final List<Song> songs =
          parsed.map<Song>((song) => Genre.fromJson(song)).toList();

      return songs;
    }

    Uri url = getUri(path: "getSongsByGenre", query: {"genre": genre});

    final response = await http.Client().get(url);

    return compute(parse, response.body);
  }

  static Future<String> ping() async {
    String parse(String responseBody) {
      try {
        final myTransformer = Xml2Json();
        myTransformer.parse(responseBody);
        var json = myTransformer.toGData();
        final parsed = jsonDecode(json)["subsonic-response"];
        final error = jsonDecode(json)["subsonic-response"]["error"];
        return error?["message"] ?? parsed["status"];
      } catch (e) {
        return e.toString();
      }
    }

    try {
      Uri url = getUri(path: "ping");

      final response = await http.Client().get(url);
      return compute(parse, response.body);
    } catch (e) {
      return "Unknown error";
    }
  }

  static String getCoverArt(String id, {int? size}) =>
      getUri(path: "getCoverArt", query: {
        "id": id,
        "size": size != null ? size.toString() : "200",
      }).toString();

  static String stream(String id, {String? maxBitrate}) {
    return getUri(path: "stream", query: {
      "id": id,
    }).toString();
  }

  static Future<Artist> getArtist(String id) async {
    Artist parse(String responseBody) {
      xmlTransformer.parse(responseBody);
      var json = xmlTransformer.toGData();

      final parsed = jsonDecode(json)["subsonic-response"]["artist"];
      final parsedAlbums =
          jsonDecode(json)["subsonic-response"]["artist"]["album"];

      List<Album>? albums = [];

      if (parsedAlbums is List) {
        albums = parsedAlbums.map((album) => Album.fromJson(album)).toList();
      } else if (parsedAlbums is Map<String, dynamic>) {
        albums.add(Album.fromJson(parsedAlbums));
      }

      print("...........................................................");
      print(parsed);
      print(parsedAlbums);
      return Artist.fromJson(parsed, albums: albums);
    }

    final response = await http.Client().get(getUri(path: "getArtist", query: {
      "id": id,
    }));

    return compute(parse, response.body);
  }

  static Future<Playlist> getPlaylist(String id) async {
    Playlist parse(String responseBody) {
      final myTransformer = Xml2Json();
      myTransformer.parse(responseBody);
      var json = myTransformer.toGData();

      final parsed = jsonDecode(json)["subsonic-response"]["playlist"];
      final parsedSongs =
          jsonDecode(json)["subsonic-response"]["playlist"]["entry"];
      List<dynamic>? songs = [];

      if (parsedSongs is List) {
        songs = parsedSongs;
      } else if (parsedSongs is Map) {
        songs.add(parsedSongs);
      }

      final playlist = Playlist.fromJson(parsed, songs: songs);
      return playlist;
    }

    final response =
        await http.Client().get(getUri(path: "getPlaylist", query: {
      "id": id,
    }));

    return compute(parse, response.body);
  }

  static Future<List<Album>?> getAlbumList(String? type,
      {String? genre, String? size}) async {
    List<Album>? parseAlbums(String responseBody) {
      final myTransformer = Xml2Json();

      myTransformer.parse(responseBody);
      var json = myTransformer.toGData();

      final parsed =
          jsonDecode(json)["subsonic-response"]["albumList2"]["album"];
      List<Album> albums = [];
      if (parsed is Map<String, dynamic>) {
        albums.add(Album.fromJson(parsed));
      } else if (parsed != null) {
        albums = parsed.map<Album>((song) => Album.fromJson(song)).toList();
      } else {
        return null;
      }

      return albums;
    }

    Uri url = getUri(path: "getAlbumList2", query: {
      "type": type,
      "genre": genre ?? "",
      "size": size ?? "",
    });

    final response = await http.Client().get(url);

    final parsedAlbums = parseAlbums(response.body);

    if (parsedAlbums != null) return parsedAlbums;

    return null;
  }

  static Future<List<Album>> search(String query) async {
    List<Album> parseResults(String responseBody) {
      final myTransformer = Xml2Json();

      myTransformer.parse(responseBody);
      var json = myTransformer.toGData();

      final parsedAlbums =
          jsonDecode(json)["subsonic-response"]["searchResult3"]["album"];
      final parsedSongs =
          jsonDecode(json)["subsonic-response"]["searchResult3"]["song"];
      final parsedArtists =
          jsonDecode(json)["subsonic-response"]["searchResult3"]["artist"];

      final albums =
          parsedAlbums.map<Album>((album) => Album.fromJson(album)).toList();

      return albums;
    }

    final response = await http.Client().get(getUri(path: "search3", query: {
      "query": query,
    }));

    return compute(parseResults, response.body);
  }

  static Future<SearchResults> search3(String query) async {
    final response = await http.Client().get(getUri(path: "search3", query: {
      "query": query,
    }));

    xmlTransformer.parse(response.body);
    var json = xmlTransformer.toGData();

    return SearchResults.fromJson(
        jsonDecode(json)["subsonic-response"]["searchResult3"]);
  }

  static Future<Album> getAlbum(String id) async {
    Album parseSongs(String responseBody) {
      final myTransformer = Xml2Json();

      myTransformer.parse(responseBody);
      var json = myTransformer.toGData();

      final parsed = jsonDecode(json)["subsonic-response"]["album"];

      return Album.fromJson(parsed);
    }

    final response = await http.Client().get(getUri(path: "getAlbum", query: {
      "id": id,
    }));

    return compute(parseSongs, response.body);
  }

  static Future<List<Song>> getSongsFromAlbum(String id) async {
    List<Song> parseSongs(String responseBody) {
      final myTransformer = Xml2Json();

      myTransformer.parse(responseBody);
      var json = myTransformer.toGData();

      final parsed = jsonDecode(json)["subsonic-response"]["album"]["song"];
      List<Song> songs = [];
      if (parsed is Map<String, dynamic>) {
        songs.add(Song.fromJson(parsed));
      } else {
        songs = parsed.map<Song>((song) => Song.fromJson(song)).toList();
      }

      return songs;
    }

    final response = await http.Client().get(getUri(path: "getAlbum", query: {
      "id": id,
    }));

    return compute(parseSongs, response.body);
  }
}
