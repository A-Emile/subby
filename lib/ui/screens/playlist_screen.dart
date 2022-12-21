import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:subby/utils/subsonic.dart';
import 'package:subby/models/playlist.dart';
import 'package:subby/models/song.dart';

import '../../providers/player_provider.dart';
import 'player_screen.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  const PlaylistDetailsScreen({super.key, required this.playlist});
  final Playlist playlist;

  @override
  PlaylistDetailsView createState() => PlaylistDetailsView();
}

class PlaylistDetailsView extends State<PlaylistDetailsScreen> {
  List<Song> songs = [];

  Future<void> _getData(String id) async {
    Playlist newPlaylist = await SubsonicAPI.getPlaylist(id);

    setState(() {
      songs = newPlaylist.songs!;
    });
  }

  @override
  void initState() {
    super.initState();
    _getData(widget.playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    Playlist playlist = widget.playlist;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _getData(playlist.id),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              actions: [
                ValueListenableBuilder(
                    valueListenable:
                        context.read<MyAudioPlayer>().currentIdNotifier,
                    builder: (context, value, child) {
                      if (value == playlist.id) {
                        return ValueListenableBuilder(
                          valueListenable:
                              context.read<MyAudioPlayer>().buttonNotifier,
                          builder: (context, value, child) {
                            switch (value) {
                              case ButtonState.loading:
                                return const CircularProgressIndicator();
                              case ButtonState.paused:
                                return IconButton(
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  iconSize: 40,
                                  onPressed: () {
                                    context.read<MyAudioPlayer>().play();
                                  },
                                );
                              case ButtonState.playing:
                                return IconButton(
                                  iconSize: 40,
                                  icon: const Icon(Icons.pause_rounded),
                                  onPressed: () {
                                    context.read<MyAudioPlayer>().pause();
                                  },
                                );
                            }
                          },
                        );
                      }
                      return IconButton(
                        onPressed: () {
                          context.read<MyAudioPlayer>().setPlaylist(
                              id: playlist.id,
                              songs: songs
                                  .map<AudioSource>((song) => AudioSource.uri(
                                      Uri.parse(SubsonicAPI.stream(song.id)),
                                      tag: MediaItem(
                                        id: song.id,
                                        album: song.albumId,
                                        title: song.title,
                                        artist: song.artist,
                                        artUri: Uri.parse(
                                            SubsonicAPI.getCoverArt(
                                                song.coverArt,
                                                size: 400)),
                                      )))
                                  .toList());
                          context.read<MyAudioPlayer>().play();
                          Get.to(const MyPlayer());
                        },
                        iconSize: 40,
                        icon: const Icon(Icons.play_arrow_rounded),
                      );
                    })
              ],
              pinned: true,
              expandedHeight: 400.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  playlist.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                background: Builder(builder: (context) {
                  if (songs.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          SubsonicAPI.getCoverArt(songs[0].coverArt, size: 50),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 50,
                          sigmaY: 50,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Center(
                            child: Hero(
                              tag: playlist.id,
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Builder(builder: (context) {
                                  const duration = Duration(milliseconds: 200);

                                  final tween =
                                      Tween<double>(begin: 0.0, end: 1.0);
                                  if (songs.length > 2) {
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          left: -16,
                                          top: -24,
                                          child: TweenAnimationBuilder(
                                            tween: tween,
                                            duration: duration,
                                            builder: (context, value, child) {
                                              // Return an AnimatedOpacity widget that animates the child widget's opacity
                                              return AnimatedOpacity(
                                                duration: duration,
                                                opacity: value,
                                                child: child,
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: Image.network(
                                                SubsonicAPI.getCoverArt(
                                                  songs[0].coverArt,
                                                  size: 300,
                                                ),
                                                width: 200,
                                                height: 200,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 32,
                                          top: -16,
                                          child: TweenAnimationBuilder(
                                            tween: tween,
                                            duration: duration,
                                            builder: (context, value, child) {
                                              // Return an AnimatedOpacity widget that animates the child widget's opacity
                                              return AnimatedOpacity(
                                                duration: duration,
                                                opacity: value,
                                                child: child,
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: Image.network(
                                                SubsonicAPI.getCoverArt(
                                                  songs[1].coverArt,
                                                  size: 300,
                                                ),
                                                width: 200,
                                                height: 200,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 14,
                                          top: 20,
                                          child: TweenAnimationBuilder(
                                            tween: tween,
                                            duration: duration,
                                            builder: (context, value, child) {
                                              // Return an AnimatedOpacity widget that animates the child widget's opacity
                                              return AnimatedOpacity(
                                                duration: duration,
                                                opacity: value,
                                                child: child,
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: Image.network(
                                                SubsonicAPI.getCoverArt(
                                                  songs[2].coverArt,
                                                  size: 300,
                                                ),
                                                width: 200,
                                                height: 200,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else if (songs.isNotEmpty) {
                                    return TweenAnimationBuilder(
                                      tween: tween,
                                      duration: duration,
                                      builder: (context, value, child) {
                                        // Return an AnimatedOpacity widget that animates the child widget's opacity
                                        return AnimatedOpacity(
                                          duration: duration,
                                          opacity: value,
                                          child: child,
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          SubsonicAPI.getCoverArt(
                                            songs[0].coverArt,
                                            size: 300,
                                          ),
                                          width: 200,
                                          height: 200,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate(
              childCount: songs.length,
              (context, index) {
                final song = songs[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      SubsonicAPI.getCoverArt(song.id, size: 80),
                      width: 40,
                      height: 40,
                    ),
                  ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    song.artist,
                    maxLines: 1,
                  ),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
