import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayManager {
  factory AudioPlayManager() => _instance;

  AudioPlayManager._internal();

  static final AudioPlayManager _instance = AudioPlayManager._internal();

  final player = AudioPlayer();

  String songUrl = '';

  Stream<DurationState>? durationState;

  void prepare({bool isNewSong = false}) {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) => DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    );
    if (isNewSong) {
      player.setUrl(songUrl);
    }
  }

  void updateSongUrl(String url) {
    songUrl = url;
    prepare();
  }

  void dispose() {
    player.dispose();
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
