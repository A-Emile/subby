import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:subby/models/song.dart';
import 'package:subby/ui/screens/player_screen.dart';

import '../../models/album.dart';
import '../../providers/player_provider.dart';
import '../../utils/subsonic.dart';
import 'album_screen.dart';

class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key, required this.genre});

  final String genre;

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  bool shuffling = false;

  @override
  Widget build(BuildContext context) {
    final audio = context.read<MyAudioPlayer>();
    return Scaffold(
      body: FutureBuilder(
        future: SubsonicAPI.getAlbumList("byGenre",
            genre: widget.genre, size: "100"),
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                flexibleSpace: FlexibleSpaceBar(title: Text(widget.genre)),
                pinned: true,
                actions: [
                  IconButton(
                    onPressed: snapshot.data != null
                        ? () async {
                            setState(() {
                              shuffling = true;
                            });
                            audio.pause();
                            await audio.playlist.clear();
                            List<Song> songs = [];
                            for (var album in snapshot.data!) {
                              songs.addAll(await SubsonicAPI.getSongsFromAlbum(
                                  album.id));
                            }
                            songs.shuffle();
                            await audio.playlist.addAll(songs
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
                            setState(() {
                              shuffling = false;
                            });
                            audio.play();
                            Get.to(() => const MyPlayer());
                          }
                        : () {},
                    icon: shuffling
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ))
                        : const Icon(Icons.shuffle),
                  )
                ],
              ),
              Builder(builder: (context) {
                if (snapshot.data == null) {
                  return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()));
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: snapshot.data!.length,
                    (context, index) {
                      Album album = snapshot.data![index];
                      return ListTile(
                        onTap: () {
                          Get.to(() => AlbumDetailsView(
                                id: album.id,
                              ));
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            SubsonicAPI.getCoverArt(album.id, size: 80),
                            width: 40,
                            height: 40,
                          ),
                        ),
                        title: Text(
                          album.name,
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          "${album.artist}, (${album.songCount} ${album.songCount > 1 ? 'songs' : 'song'})",
                          maxLines: 1,
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
