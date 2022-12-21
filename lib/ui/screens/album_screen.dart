import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:subby/utils/subsonic.dart';
import 'package:subby/ui/screens/player_screen.dart';
import 'package:subby/models/song.dart';
import 'package:subby/ui/widgets/song_list.dart';

import 'package:subby/providers/player_provider.dart';
import '../../models/album.dart';

class AlbumDetailsView extends StatefulWidget {
  // In the constructor, require a Todo.
  const AlbumDetailsView({super.key, required this.id, this.heroTag});

  static const routeName = '/album';

  // Declare a field that holds the Todo.
  final String id;

  final String? heroTag;

  @override
  State<AlbumDetailsView> createState() => _AlbumDetailsViewState();
}

class _AlbumDetailsViewState extends State<AlbumDetailsView> {
  List<Song> _songs = [];
  Album? _album;
  late Future<void> _initSongsData;

  bool showSongs = false;

  Future<void> _initAlbum() async {
    final album = await SubsonicAPI.getAlbum(widget.id);
    setState(() {
      _album = album;
    });
  }

  @override
  void initState() {
    super.initState();
    _initSongsData = _initAlbum();
  }

  @override
  Widget build(BuildContext context) {
    final MyAudioPlayer audio = context.read();

    // Use the Todo to create the UI.
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(
              _album?.name ?? "",
              maxLines: 3,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            pinned: true,
            expandedHeight: 350.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        SubsonicAPI.getCoverArt(widget.id, size: 300)),
                  ),
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 50,
                      sigmaY: 50,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context)
                                .scaffoldBackgroundColor
                                .withOpacity(0.1),
                            Theme.of(context).scaffoldBackgroundColor
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Center(
                          child: Hero(
                            tag: widget.heroTag ?? widget.id,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                SubsonicAPI.getCoverArt(widget.id, size: 300),
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Builder(builder: (context) {
            if (_album == null) {
              return const SliverToBoxAdapter(
                child: SizedBox(height: 82),
              );
            }
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _album?.artist ?? "",
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            _album!.songCount > 1
                                ? '${_album!.songCount} songs - ${_album!.year}'
                                : 'Single - ${_album!.year}',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    RatingBar.builder(
                      glowColor: Theme.of(context).colorScheme.primary,
                      initialRating: double.parse(_album?.rating ?? "0"),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      itemSize: 25,
                      onRatingUpdate: (rating) {
                        SubsonicAPI.setRating(_album!.id, rating.toInt());
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                    onPressed: null,
                    icon: Icon(Icons.download_rounded),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                    onPressed: () async {
                      await SubsonicAPI.getSongsFromAlbum(widget.id)
                          .then((songs) {
                        setState(() {
                          _songs = songs;
                        });
                        context.read<MyAudioPlayer>().setPlaylist(
                            id: widget.id,
                            songs: _songs
                                .map<AudioSource>((song) => AudioSource.uri(
                                    Uri.parse(SubsonicAPI.stream(song.id)),
                                    tag: MediaItem(
                                      id: song.id,
                                      album: song.albumId,
                                      title: song.title,
                                      artist: song.artist,
                                      artUri: Uri.parse(SubsonicAPI.getCoverArt(
                                          song.coverArt,
                                          size: 400)),
                                    )))
                                .toList());
                        context.read<MyAudioPlayer>().play();
                        Get.to(() => const MyPlayer());
                      });
                    },
                    child: const SizedBox(
                      width: 80,
                      child: Icon(Icons.play_arrow_rounded),
                    ),
                  ),
                  IconButton(
                    tooltip: _album?.starred != null ? "unstar" : "star",
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withOpacity(0.5),
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                    onPressed: () async {
                      _album?.starred == null
                          ? SubsonicAPI.star(_album!.id)
                          : SubsonicAPI.unstar(_album!.id);

                      setState(() {
                        _album = Album(
                            id: _album!.id,
                            name: _album!.name,
                            year: _album!.year,
                            coverArt: _album!.coverArt,
                            artist: _album!.artist,
                            songCount: _album!.songCount,
                            starred: _album?.starred == null
                                ? DateTime.now().toIso8601String()
                                : null);
                      });
                    },
                    icon: _album != null
                        ? Icon(_album?.starred != null
                            ? Icons.star_rounded
                            : Icons.star_border_rounded)
                        : const SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            )),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    foregroundColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.5),
                  ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                  onPressed: () async {
                    if (_songs.isEmpty) {
                      final songs =
                          await SubsonicAPI.getSongsFromAlbum(widget.id);
                      setState(() {
                        _songs = songs;
                      });
                    }
                    setState(() {
                      showSongs = !showSongs;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Songs"),
                      Icon(!showSongs
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_up_rounded),
                    ],
                  )),
            ),
          ),
          Builder(
            builder: (context) {
              if (showSongs) {
                return Builder(builder: (context) {
                  if (_songs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return SongListView(
                    songs: _songs,
                  );
                });
              } else {
                return const SliverToBoxAdapter();
              }
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          )
        ],
      ),
    );
  }
}
