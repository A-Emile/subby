import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import '../../providers/player_provider.dart';
import '../screens/player_screen.dart';

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MediaItem?>(
        valueListenable: context.read<MyAudioPlayer>().currentNotifier,
        builder: (_, song, __) {
          if (song == null) {
            return const SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.only(right: 5, left: 5, bottom: 5),
            child: GestureDetector(
              onHorizontalDragEnd: (DragEndDetails details) {
                // Swiping in right direction.
                if (details.primaryVelocity! < 0) {
                  context.read<MyAudioPlayer>().seekToNext();
                }
                // Swiping in left direction.
                if (details.primaryVelocity! > 0) {
                  context.read<MyAudioPlayer>().seekToPrevious();
                }
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  Get.to(() => const MyPlayer(),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 200));
                }
              },
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context)
                          .buttonTheme
                          .colorScheme!
                          .background
                          .withOpacity(0.9)),
                  shadowColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(0)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side:
                            BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                ),
                onPressed: () => Get.to(() => const MyPlayer(),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 200)),
                child: SizedBox(
                  height: 55,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 1),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 39,
                            child: ValueListenableBuilder<MediaItem?>(
                              valueListenable:
                                  context.read<MyAudioPlayer>().currentNotifier,
                              builder: (_, song, __) {
                                if (song == null) {
                                  return const SizedBox();
                                }
                                return Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        song.artUri.toString(),
                                        fit: BoxFit.cover,
                                        width: 39,
                                        height: 39,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            song.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Text(
                                            song.artist ?? "",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                          ValueListenableBuilder<ButtonState>(
                            valueListenable:
                                context.read<MyAudioPlayer>().buttonNotifier,
                            builder: (_, value, __) {
                              switch (value) {
                                case ButtonState.loading:
                                  return const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(),
                                  );
                                case ButtonState.paused:
                                  return IconButton(
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    iconSize: 36,
                                    alignment: Alignment.topCenter,
                                    onPressed: () {
                                      context.read<MyAudioPlayer>().play();
                                    },
                                  );
                                case ButtonState.playing:
                                  return IconButton(
                                    icon: const Icon(Icons.pause_rounded),
                                    iconSize: 36,
                                    onPressed: () {
                                      context.read<MyAudioPlayer>().pause();
                                    },
                                  );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
