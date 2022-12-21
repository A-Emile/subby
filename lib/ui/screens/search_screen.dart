import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:subby/models/album.dart';
import 'package:subby/models/artist.dart';
import 'package:subby/models/genre.dart';
import 'package:subby/models/song.dart';
import 'package:subby/ui/screens/album_screen.dart';
import 'package:subby/ui/screens/artist_screen.dart';
import 'package:subby/ui/widgets/genre_list.dart';
import 'package:subby/utils/random.dart';
import 'package:subby/utils/subsonic.dart';

import '../widgets/album_list.dart';
import 'genre_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _query;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: TextFormField(
              onChanged: (query) {
                setState(() {
                  setState(() {
                    _query = query;
                  });
                });
              },
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
              ),
            ),
            actions: _query != ""
                ? [
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _query = "";
                        });
                      },
                      icon: const Icon(Icons.close),
                    )
                  ]
                : null,
          ),
          body: Builder(builder: (context) {
            if (_query != null && _query!.isNotEmpty) {
              return FutureBuilder(
                  future: SubsonicAPI.search3(_query ?? ""),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final List<Album>? albums = snapshot.data!.albums;
                    final List<Song>? songs = snapshot.data!.songs;
                    final List<Artist>? artists = snapshot.data!.artists;

                    return Column(
                      children: [
                        TabBar(
                          padding: const EdgeInsets.only(
                              right: 8, left: 8, top: 8, bottom: 4),
                          labelPadding:
                              const EdgeInsets.only(left: 3, right: 3),
                          splashBorderRadius: BorderRadius.circular(25),
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ),
                            border: Border.all(
                                color: Theme.of(context)
                                        .buttonTheme
                                        .colorScheme
                                        ?.primary ??
                                    Theme.of(context).dividerColor),
                          ),
                          labelStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                          labelColor: Theme.of(context)
                              .buttonTheme
                              .colorScheme
                              ?.primary,
                          tabs: const [
                            Tab(
                              text: "Albums",
                            ),
                            Tab(
                              text: "Songs",
                            ),
                            Tab(
                              text: "Artists",
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ListView.builder(
                                itemCount: albums!.length,
                                itemBuilder: (context, index) {
                                  Album album = albums[index];
                                  return ListTile(
                                    onTap: () {
                                      Get.to(() => AlbumDetailsView(
                                            id: album.id,
                                          ));
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        fit: BoxFit.cover,
                                        SubsonicAPI.getCoverArt(album.id,
                                            size: 80),
                                        width: 40,
                                        height: 40,
                                      ),
                                    ),
                                    title: Text(
                                      album.name,
                                      maxLines: 1,
                                    ),
                                    subtitle: Text(
                                      album.artist,
                                      maxLines: 1,
                                    ),
                                  );
                                },
                              ),
                              ListView.builder(
                                itemCount: songs!.length,
                                itemBuilder: (context, index) {
                                  Song song = songs[index];
                                  return ListTile(
                                    onTap: () {},
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        fit: BoxFit.cover,
                                        SubsonicAPI.getCoverArt(song.id,
                                            size: 80),
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
                              ),
                              ListView.builder(
                                itemCount: artists!.length,
                                itemBuilder: (context, index) {
                                  Artist artist = artists[index];
                                  return ListTile(
                                    onTap: () {
                                      Get.to(() => ArtistScreen(
                                            artist: artist,
                                          ));
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        fit: BoxFit.cover,
                                        SubsonicAPI.getCoverArt(
                                            artist.coverArt ?? "",
                                            size: 80),
                                        width: 40,
                                        height: 40,
                                      ),
                                    ),
                                    title: Text(
                                      artist.name,
                                      maxLines: 1,
                                    ),
                                    subtitle: Text(
                                      "${artist.albumCount} ${artist.albumCount! > 1 ? 'Albums' : 'Album'}",
                                      maxLines: 1,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  });
            } else {
              return GenreList(
                onGenreSelected: (genre) {
                  Get.to(() => GenreScreen(
                        genre: genre,
                      ));
                },
              );
            }
          })),
    );
  }
}
