import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class MyAudioPlayer with ChangeNotifier {
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

  final skipNotifier = ValueNotifier<SkipState>(
    SkipState(hasNext: false, hasPrevious: false),
  );

  final currentNotifier = ValueNotifier<MediaItem?>(null);

  final currentIdNotifier = ValueNotifier<String?>(null);

  final sequenceNotifier = ValueNotifier<SequenceState?>(null);

  final _playlist = ConcatenatingAudioSource(children: []);

  late AudioPlayer _audioPlayer;

  AudioPlayer get player => _audioPlayer;
  ConcatenatingAudioSource get playlist => _playlist;
  MyAudioPlayer() {
    _init();
  }

  void _init() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setAudioSource(_playlist);

    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } else {
        buttonNotifier.value = ButtonState.playing;
      }
    });

    _audioPlayer.sequenceStateStream.listen((state) {
      final MediaItem? metadata = state?.currentSource?.tag;
      currentNotifier.value = metadata;
      sequenceNotifier.value = state;
      skipNotifier.value = SkipState(
          hasNext: _audioPlayer.hasNext, hasPrevious: _audioPlayer.hasPrevious);
    });

    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });

    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });

    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void play({AudioSource? song}) {
    if (song != null) {
      int? index = _audioPlayer.currentIndex;
      _playlist.insert(index! - 1, song);
      _audioPlayer.seek(Duration.zero, index: index);
    }
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position, {int? index}) {
    _audioPlayer.seek(position, index: index);
  }

  void seekToNext() => _audioPlayer.seekToNext();

  void seekToPrevious() => _audioPlayer.seekToPrevious();

  insertInPlaylist(AudioSource song) {
    _playlist.insert(_audioPlayer.currentIndex ?? 0, song);
  }

  addToPlaylist(AudioSource song, {bool? play}) async {
    if (play == true) {
      final i = _audioPlayer.currentIndex;
      await _playlist.insert(i ?? 0, song);
      _audioPlayer.seek(Duration.zero, index: i);
    } else {
      final i = _audioPlayer.currentIndex;
      await _playlist.insert(i ?? 0, song);
    }
  }

  List<AudioSource> get getPlaylist {
    return _playlist.children;
  }

  Future<void> setPlaylist(
      {required List<AudioSource> songs, required String id}) async {
    currentIdNotifier.value = id;
    await _playlist.clear();
    await _playlist.addAll(songs);
  }

  void clearPlaylist(List<AudioSource> songs) async {
    await _playlist.clear();
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState { paused, playing, loading }

class SkipState {
  SkipState({
    required this.hasNext,
    required this.hasPrevious,
  });
  final bool hasNext;
  final bool hasPrevious;
}
