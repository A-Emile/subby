import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subby/models/playlist.dart';
import 'package:subby/ui/screens/playlist_create_screen.dart';
import 'package:subby/ui/screens/playlist_screen.dart';

import '../../utils/subsonic.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with AutomaticKeepAliveClientMixin<LibraryScreen> {
  @override
  bool get wantKeepAlive => true;

  List<Playlist> playlists = [];

  Future<void> _getData() async {
    List<Playlist> newPlaylists = await SubsonicAPI.getPlaylists();

    setState(() {
      playlists = newPlaylists;
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Library"),
          actions: [
            IconButton(
                onPressed: () {
                  Get.bottomSheet(
                      isDismissible: true,
                      SizedBox(
                        height: 100,
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text("Add Playlist"),
                              leading: const Icon(Icons.add),
                              onTap: () =>
                                  Get.to(() => const PlaylistCreateScreen()),
                            ),
                          ],
                        ),
                      ),
                      backgroundColor:
                          Theme.of(context).buttonTheme.colorScheme?.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ));
                },
                icon: Icon(Icons.menu))
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                text: "Playlists",
              ),
              Tab(
                text: "Downloads",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _getData,
              child: ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  Playlist playlist = playlists[index];
                  return InkWell(
                    onTap: () {
                      Get.to(() => PlaylistDetailsScreen(playlist: playlist));
                    },
                    child: ListTile(
                      title: Text(playlist.name),
                      subtitle: Text(
                          "${playlist.songCount} ${playlist.songCount.length > 1 ? 'songs' : 'song'}"),
                    ),
                  );
                },
              ),
            ),
            const Center(
              child: Text("No downloads"),
            ),
          ],
        ),
      ),
    );
  }
}
