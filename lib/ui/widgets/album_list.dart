import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/subsonic.dart';
import '../../utils/random.dart';
import '../../models/album.dart';
import '../screens/album_screen.dart';

/// Displays a list of SampleItems.
class AlbumList extends StatelessWidget {
  const AlbumList({super.key, required this.type, required this.title});

  final String type;
  final String title;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Album>?>(
      future: SubsonicAPI.getAlbumList(type),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return const Center(
            child: Text('An error has occurred!'),
          );
        } else if (snapshot.hasData) {
          return AlbumListView(
            albums: snapshot.data!,
            title: title,
          );
        } else if (snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class AlbumListView extends StatelessWidget {
  const AlbumListView({super.key, required this.albums, required this.title});
  final List<Album> albums;

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(title.toUpperCase().substring(0, 1) + title.substring(1),
              style:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        Builder(builder: (context) {
          if (albums.isEmpty) {
            return Center(child: Text("No $title albums"));
          }
          return SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                final heroTag = album.id + randomString(5);
                return Container(
                  margin: const EdgeInsets.only(left: 10.0),
                  width: 150,
                  child: InkWell(
                    onTap: () => {
                      Get.to(() => AlbumDetailsView(
                            id: album.id,
                            heroTag: heroTag,
                          ))
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Hero(
                          tag: heroTag,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              SubsonicAPI.getCoverArt(album.id, size: 300),
                              height: 150,
                              width: 150,
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: 0.8,
                          child: Text(
                            album.name,
                            maxLines: 2,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
