import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:subby/models/album.dart';
import '../../utils/subsonic.dart';
import '../../providers/player_provider.dart';
import "package:provider/provider.dart";

import 'album_screen.dart';

class MyPlayer extends StatelessWidget {
  const MyPlayer({Key? key}) : super(key: key);

  static const routeName = '/player';

  @override
  Widget build(BuildContext context) {
    final MyAudioPlayer audio = context.read();
    return ValueListenableBuilder<MediaItem?>(
      valueListenable: context.read<MyAudioPlayer>().currentNotifier,
      builder: (_, song, __) {
        return GestureDetector(
          onHorizontalDragEnd: (DragEndDetails details) {
            // Swiping in right direction.
            if (details.primaryVelocity! < 0) {
              audio.seekToNext();
            }
            // Swiping in left direction.
            if (details.primaryVelocity! > 0) {
              audio.seekToPrevious();
            }
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              Get.back();
            }
            if (details.primaryVelocity! < 0) {
              Get.to(
                  transition: Transition.downToUp,
                  duration: const Duration(milliseconds: 200),
                  () => const QueueView());
            }
          },
          child: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(song?.artUri.toString() ?? ""),
                fit: BoxFit.cover,
              ),
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 50,
                  sigmaY: 50,
                ),
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    title: const Text("Now playing "),
                    leading: IconButton(
                      iconSize: 36,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  backgroundColor: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.5),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Builder(builder: (context) {
                            if (song != null && song.artUri != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  song.artUri.toString(),
                                  fit: BoxFit.cover,
                                ),
                              );
                            }
                            return const CircularProgressIndicator();
                          }),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: InkWell(
                          onTap: () {
                            Get.to(() => AlbumDetailsView(
                                  id: song?.album ?? "",
                                ));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song?.title ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(
                                song?.artist ?? "",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        ?.color
                                        ?.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ValueListenableBuilder<ProgressBarState>(
                        valueListenable:
                            context.read<MyAudioPlayer>().progressNotifier,
                        builder: (_, value, __) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: ProgressBar(
                              onSeek: context.read<MyAudioPlayer>().seek,
                              progress: value.current,
                              buffered: value.buffered,
                              total: value.total,
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StreamBuilder<bool>(
                              stream: audio.player.shuffleModeEnabledStream,
                              builder: (context, snapshot) {
                                final shuffleModeEnabled =
                                    snapshot.data ?? false;
                                return IconButton(
                                  icon: shuffleModeEnabled
                                      ? Icon(Icons.shuffle,
                                          color: Theme.of(context)
                                              .buttonTheme
                                              .colorScheme
                                              ?.primary)
                                      : const Icon(
                                          Icons.shuffle,
                                        ),
                                  onPressed: () async {
                                    final enable = !shuffleModeEnabled;
                                    if (enable) {
                                      await audio.player.shuffle();
                                    }
                                    await audio.player
                                        .setShuffleModeEnabled(enable);
                                  },
                                );
                              },
                            ),
                            const Spacer(),
                            ValueListenableBuilder<SkipState>(
                              valueListenable:
                                  context.read<MyAudioPlayer>().skipNotifier,
                              builder: (_, state, __) {
                                return IconButton(
                                    icon:
                                        const Icon(Icons.skip_previous_rounded),
                                    iconSize: 46,
                                    disabledColor: Colors.white30,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    tooltip: state.hasPrevious.toString(),
                                    onPressed: state.hasPrevious
                                        ? () => context
                                            .read<MyAudioPlayer>()
                                            .seekToPrevious()
                                        : null);
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 22, right: 20),
                              child: ValueListenableBuilder<ButtonState>(
                                valueListenable: context
                                    .read<MyAudioPlayer>()
                                    .buttonNotifier,
                                builder: (_, value, __) {
                                  switch (value) {
                                    case ButtonState.loading:
                                      return Container(
                                        margin: const EdgeInsets.all(10),
                                        width: 64,
                                        height: 64,
                                        child:
                                            const CircularProgressIndicator(),
                                      );
                                    case ButtonState.paused:
                                      return IconButton(
                                        icon: const Icon(
                                            Icons.play_arrow_rounded),
                                        iconSize: 64,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                                  EdgeInsets>(
                                              const EdgeInsets.all(10)),
                                        ),
                                        onPressed: () {
                                          context.read<MyAudioPlayer>().play();
                                        },
                                      );
                                    case ButtonState.playing:
                                      return IconButton(
                                        icon: const Icon(Icons.pause_rounded),
                                        iconSize: 64,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                                  EdgeInsets>(
                                              const EdgeInsets.all(10)),
                                        ),
                                        onPressed: () {
                                          context.read<MyAudioPlayer>().pause();
                                        },
                                      );
                                  }
                                },
                              ),
                            ),
                            ValueListenableBuilder<SkipState>(
                              valueListenable:
                                  context.read<MyAudioPlayer>().skipNotifier,
                              builder: (_, state, __) {
                                return IconButton(
                                  icon: const Icon(Icons.skip_next_rounded),
                                  iconSize: 46,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                  disabledColor: Colors.white30,
                                  onPressed: state.hasNext
                                      ? () => context
                                          .read<MyAudioPlayer>()
                                          .seekToNext()
                                      : null,
                                );
                              },
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                Get.to(
                                    transition: Transition.downToUp,
                                    duration: const Duration(milliseconds: 200),
                                    () => const QueueView());
                              },
                              icon: const Icon(Icons.list_rounded),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class QueueView extends StatelessWidget {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.read<MyAudioPlayer>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Queue"),
        actions: [
          StreamBuilder<LoopMode>(
            stream: audio.player.loopModeStream,
            builder: (context, snapshot) {
              final loopMode = snapshot.data ?? LoopMode.off;
              final icons = [
                const Icon(Icons.repeat),
                Icon(Icons.repeat,
                    color: Theme.of(context).buttonTheme.colorScheme?.primary),
                Icon(Icons.repeat_one,
                    color: Theme.of(context).buttonTheme.colorScheme?.primary),
              ];
              const cycleModes = [
                LoopMode.off,
                LoopMode.all,
                LoopMode.one,
              ];
              final index = cycleModes.indexOf(loopMode);
              return IconButton(
                icon: icons[index],
                onPressed: () {
                  audio.player.setLoopMode(cycleModes[
                      (cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
                },
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<SequenceState?>(
        valueListenable: context.read<MyAudioPlayer>().sequenceNotifier,
        builder: (_, state, __) {
          final sequence = state?.sequence ?? [];
          double? initialScrollOffset = state?.currentIndex.toDouble();

          return ReorderableListView.builder(
            scrollController: ScrollController(
                initialScrollOffset:
                    initialScrollOffset != null ? initialScrollOffset * 70 : 0),
            onReorder: (int oldIndex, int newIndex) {
              if (oldIndex < newIndex) newIndex--;
              audio.playlist.move(oldIndex, newIndex);
            },
            itemCount: sequence.length,
            itemBuilder: (context, index) {
              return Dismissible(
                onDismissed: (dismissDirection) {
                  audio.playlist.removeAt(index);
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
                key: ValueKey(sequence[index]),
                child: SizedBox(
                  height: 70,
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      onTap: () {
                        audio.player.seek(Duration.zero, index: index);
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          SubsonicAPI.getCoverArt(state?.sequence[index].tag.id,
                              size: 80),
                          width: 40,
                          height: 40,
                        ),
                      ),
                      textColor: index == state?.currentIndex
                          ? Theme.of(context).buttonTheme.colorScheme?.primary
                          : Theme.of(context).textTheme.bodyText2?.color,
                      title: Text(
                        state?.sequence[index].tag.title as String,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        style: const TextStyle(color: Colors.grey),
                        state?.sequence[index].tag.artist as String,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
