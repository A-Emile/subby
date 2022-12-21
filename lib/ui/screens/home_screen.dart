import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subby/utils/subsonic.dart';
import 'package:subby/ui/screens/settings_screen.dart';

import '../../utils/shared_preferences.dart';
import '../widgets/album_list.dart';

List<String> availibleHomeItems = const [
  "newest",
  "random",
  "frequent",
  "starred",
  "recent"
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class HomeItem {
  const HomeItem({
    required this.type,
    required this.title,
  });

  final String type;
  final String title;
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;

  List<AlbumListView> _homeViews = [];

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<String> defaultHomeItems = const [
    "random",
    "newest",
    "frequent",
    "recent",
    "starred"
  ];

  Future<void> _getData() async {
    List<AlbumListView> newHomeViews = [];

    final SharedPreferences prefs = await _prefs;

    for (var item in prefs.getStringList("homeItems") ?? defaultHomeItems) {
      var albums = await SubsonicAPI.getAlbumList(item);
      newHomeViews.add(AlbumListView(albums: albums ?? [], title: item));
    }

    setState(() {
      _homeViews = newHomeViews;
    });
  }

  @override
  void initState() {
    super.initState();

    _prefs.then((SharedPreferences prefs) {
      if (prefs.getStringList("homeItems") == null) {
        prefs.setStringList('homeItems', defaultHomeItems);
      }
    });
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Subby"),
        actions: [
          IconButton(
              onPressed: () => Get.to(() => const SettingsScreen()),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Builder(builder: (context) {
        if (_homeViews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: _getData,
          child: ReorderableListView.builder(
            itemCount:
                UserSettings.prefs().getStringList("homeItems")?.length ?? 0,
            onReorder: (int oldIndex, int newIndex) {
              debugPrint("object");
              if (oldIndex < newIndex) newIndex--;
              List<String> newItems =
                  UserSettings.prefs().getStringList("homeItems")!;

              List<AlbumListView> newViews = _homeViews;

              final String item = newItems.removeAt(oldIndex);
              newItems.insert(newIndex, item);

              final view = newViews.removeAt(oldIndex);

              newViews.insert(newIndex, view);

              setState(() {
                _homeViews = newViews;
              });

              UserSettings.prefs().setStringList("homeItems", newItems);
              print(UserSettings.prefs().getStringList("homeItems"));
            },
            itemBuilder: (context, index) {
              return AlbumListView(
                  key: Key(_homeViews[index].title),
                  albums: _homeViews[index].albums,
                  title: _homeViews[index].title);
            },
          ),
        );
      }),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
