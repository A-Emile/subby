import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:subby/utils/connectivity.dart';
import 'package:subby/ui/screens/library_screen.dart';
import 'package:subby/ui/screens/home_screen.dart';
import 'package:subby/ui/screens/search_screen.dart';
import 'package:subby/ui/widgets/bottom_player.dart';
import 'package:subby/utils/shared_preferences.dart';
import 'package:subby/utils/subsonic.dart';

import 'providers/player_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'github.a-emile.subby.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  await UserSettings.init();

  // WidgetsFlutterBinding.ensureInitialized();
  //SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //  systemNavigationBarColor: Colors.transparent,
  //));
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => MyAudioPlayer(),
      ),
      ChangeNotifierProvider(
        create: (_) => ConnProvider(),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int selectedPageIndex = 0;
  final pages = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];
  late PageController pageController;

  @override
  void initState() {
    super.initState();

    pageController = PageController(initialPage: selectedPageIndex);
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return GetMaterialApp(
          scrollBehavior: MyCustomScrollBehavior(),
          supportedLocales: const [
            Locale('en', ''),
          ],
          theme: ThemeData(
            colorScheme: lightColorScheme ?? _defaultLightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
            scaffoldBackgroundColor:
                darkColorScheme?.background ?? Colors.black,
            useMaterial3: true,
          ),
          home: Scaffold(
            body: Stack(children: [
              PageView(
                onPageChanged: (value) => setState(() {
                  selectedPageIndex = value;
                }),
                controller: pageController,
                children: pages,
              ),
              const Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: BottomPlayer(),
              ),
            ]),
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedPageIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedPageIndex = value;
                  pageController.jumpToPage(selectedPageIndex);
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: "Home",
                  selectedIcon: Icon(Icons.home_rounded),
                ),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  label: "Search",
                  selectedIcon: Icon(Icons.search),
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_music_outlined),
                  label: "Library",
                  selectedIcon: Icon(Icons.library_music),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
