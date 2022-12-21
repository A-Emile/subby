import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:subby/models/artist.dart';
import 'package:subby/ui/screens/album_screen.dart';
import 'package:subby/utils/subsonic.dart';

class ArtistScreen extends StatefulWidget {
  const ArtistScreen({super.key, this.artist});
  final Artist? artist;
  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(widget.artist?.name ?? "Artist"),
            elevation: 450,
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text("Popular releases",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          FutureBuilder<Artist>(
              future: SubsonicAPI.getArtist(widget.artist!.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                      child: CircularProgressIndicator());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: 5,
                    (BuildContext context, int index) {
                      final album = snapshot.data!.albums?[index];
                      return ListTile(
                        onTap: () => Get.to(() => AlbumDetailsView(
                              id: album.id,
                            )),
                        title: Text(album?.name ?? "lol"),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            SubsonicAPI.getCoverArt(album?.coverArt ?? "",
                                size: 50),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        subtitle: Text(
                            "${album?.year} - ${album!.songCount > 1 ? '${album.songCount} songs' : 'Single'}"),
                      );
                    },
                  ),
                );
              }),
        ],
      ),
    );
  }
}
