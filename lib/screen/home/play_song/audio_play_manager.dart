import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayManager {
  String songUrl;

  AudioPlayManager({required this.songUrl});

  final player = AudioPlayer();

  Stream<DurationState>? durationState;

  void init() {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) => DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    );
    player.setUrl(songUrl);
  }
}

class DurationState {
  final Duration progress;
  final Duration buffered;
  final Duration? total;

  DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
}
