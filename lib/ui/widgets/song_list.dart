import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:subby/providers/player_provider.dart';
import 'package:subby/models/song.dart';

import '../../utils/subsonic.dart';

/// Displays a list of SampleItems.
class SongList extends StatelessWidget {
  const SongList({super.key, required this.id});

  final String id;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Song>>(
      future: SubsonicAPI.getSongsFromAlbum(id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return const SliverToBoxAdapter(
            child: Center(child: Text("An error occured!")),
          );
        } else if (snapshot.hasData) {
          return Column(
            children: [
              SongListView(
                songs: snapshot.data!,
              ),
            ],
          );
        } else {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class SongListView extends StatelessWidget {
  const SongListView({super.key, required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final song = songs[index];
          return Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                context.read<MyAudioPlayer>().addToPlaylist(
                    AudioSource.uri(
                      Uri.parse(SubsonicAPI.stream(song.id)),
                      tag: MediaItem(
                        id: song.id,
                        album: song.albumId,
                        title: song.title,
                        artist: song.artist,
                        artUri: Uri.parse(
                            SubsonicAPI.getCoverArt(song.coverArt, size: 400)),
                      ),
                    ),
                    play: true);
                context.read<MyAudioPlayer>().play();
              },
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 8.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    SubsonicAPI.getCoverArt(song.coverArt),
                    width: 30,
                    height: 30,
                  ),
                ),
                title: Text(
                  song.title,
                  maxLines: 1,
                ),
              ),
            ),
          );
        },
        childCount: songs.length,
      ),
    );
  }
}
