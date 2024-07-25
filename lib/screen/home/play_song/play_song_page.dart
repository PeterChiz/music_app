import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/utils/constants/colors.dart';
import 'package:music_app/utils/constants/sizes.dart';

import '../../../data/model/song.dart';
import 'audio_play_manager.dart';
import 'media_button_control.dart';

class PlaySongPage extends StatefulWidget {
  const PlaySongPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final Song playingSong;
  final List<Song> songs;

  @override
  State<PlaySongPage> createState() => _PlaySongPageState();
}

class _PlaySongPageState extends State<PlaySongPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late AudioPlayManager _audioPlayManager;
  late int _selectedItemIndex;
  late Song _song;
  double _currentAnimationPosition = 0.0;
  bool _isShuffle = false;
  late LoopMode _loopMode;

  @override
  void initState() {
    _song = widget.playingSong;
    _imageAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 12000));
    _audioPlayManager = AudioPlayManager();
    if (_audioPlayManager.songUrl.compareTo(_song.source) != 0) {
      _audioPlayManager.updateSongUrl(_song.source);
      _audioPlayManager.prepare(isNewSong: true);
    } else {
      _audioPlayManager.prepare(isNewSong: false);
    }
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    _loopMode = LoopMode.off;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Phát nhạc',
        ),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ), //1
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: SizesApp.spaceMaxSections,
              ),
              Text(_song.album),
              const SizedBox(
                height: SizesApp.spaceBtwItems,
              ),
              const Text('_ ___ _'), //need change
              const SizedBox(
                height: SizesApp.spaceBtwSections,
              ), //2

              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0)
                    .animate(_imageAnimationController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/music_loading.png',
                    image: _song.image,
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    imageErrorBuilder: (context, error, stackTrade) {
                      return Image.asset(
                        'assets/images/music_loading.png',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    },
                  ),
                ),
              ), //3

              Padding(
                padding: const EdgeInsets.only(top: 64, bottom: 16),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(_song.title),
                          const SizedBox(
                            height: SizesApp.spaceSongItems,
                          ),
                          Text(
                            _song.artist,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.favorite_outline,
                        ),
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ],
                  ),
                ),
              ), //4
              Padding(
                padding: const EdgeInsets.only(
                  top: 32,
                  left: 24,
                  right: 24,
                  bottom: 0,
                ),
                child: _progressBar(),
              ), //5
              const SizedBox(
                height: SizesApp.spaceBtwItems,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 0,
                  bottom: 16,
                ),
                child: _mediaButtons(),
              ), //6
            ],
          ),
        ),
      ), //2
    );
  }

  @override
  void dispose() {
    _imageAnimationController.dispose();
    super.dispose();
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
            function: _setShuffle,
            icon: Icons.shuffle,
            size: 24,
            color: _getShuffleColor(),
          ),
          MediaButtonControl(
              function: _setPrevSong,
              icon: Icons.skip_previous,
              size: 36,
              color: ColorsApp.spotify),
          _playButton(),
          MediaButtonControl(
              function: _setNextSong,
              icon: Icons.skip_next,
              size: 36,
              color: ColorsApp.spotify),
          MediaButtonControl(
            function: _setupRepeatOption,
            icon: _repeatingIcon(),
            size: 24,
            color: _getRepeatingIconColor(),
          ),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            onSeek: _audioPlayManager.player.seek,
            barHeight: 5.0,
            barCapShape: BarCapShape.round,
            baseBarColor: Colors.grey.withOpacity(0.3),
            progressBarColor: Colors.greenAccent,
            bufferedBarColor: Colors.grey.withOpacity(0.3),
            thumbColor: ColorsApp.spotify,
            thumbGlowColor: Colors.greenAccent,
            thumbRadius: 10.0,
          );
        }); //5
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
        stream: _audioPlayManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playState = snapshot.data;
          final processingState = playState?.processingState;
          final playing = playState?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            _pauseRotationAnimation();
            return Container(
              margin: const EdgeInsets.all(8),
              width: 48,
              height: 48,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true) {
            return MediaButtonControl(
                function: () {
                  _audioPlayManager.player.play();
                },
                icon: Icons.play_arrow,
                size: 48,
                color: ColorsApp.spotify);
          } else if (processingState != ProcessingState.completed) {
            _playRotationAnimation();
            return MediaButtonControl(
                function: () {
                  _audioPlayManager.player.pause();
                  _pauseRotationAnimation();
                },
                icon: Icons.pause,
                size: 48,
                color: ColorsApp.spotify);
          } else {
            if (processingState == ProcessingState.completed) {
              _stopRotationAnimation();
              _resetRotationAnimation();
            }
            return MediaButtonControl(
              function: () {
                _audioPlayManager.player.seek(Duration.zero);
                _resetRotationAnimation();
                _playRotationAnimation();
              },
              icon: Icons.replay,
              size: 48,
              color: ColorsApp.spotify,
            );
          }
        });
  }

  void _setNextSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex < widget.songs.length - 1) {
      ++_selectedItemIndex;
    } else if (_loopMode == LoopMode.all &&
        _selectedItemIndex == widget.songs.length - 1) {
      _selectedItemIndex = 0;
    }
    if (_selectedItemIndex >= widget.songs.length) {
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayManager.updateSongUrl(nextSong.source);
    _resetRotationAnimation();
    setState(() {
      _song = nextSong;
    });
  }

  void _setPrevSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex > 0) {
      --_selectedItemIndex;
    } else if (_loopMode == LoopMode.all && _selectedItemIndex == 0) {
      _selectedItemIndex = widget.songs.length - 1;
    }
    if (_selectedItemIndex < 0) {
      _selectedItemIndex = (-1 * _selectedItemIndex) % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayManager.updateSongUrl(nextSong.source);
    _resetRotationAnimation();
    setState(() {
      _song = nextSong;
    });
  }

  void _playRotationAnimation() {
    _imageAnimationController.forward(from: _currentAnimationPosition);
    _imageAnimationController.repeat();
  }

  void _pauseRotationAnimation() {
    _stopRotationAnimation();
    _currentAnimationPosition = _imageAnimationController.value;
  }

  void _stopRotationAnimation() {
    _imageAnimationController.stop();
  }

  void _resetRotationAnimation() {
    _currentAnimationPosition = 0.0;
    _imageAnimationController.value = _currentAnimationPosition;
  }

  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color? _getShuffleColor() {
    return _isShuffle ? ColorsApp.spotify : Colors.grey;
  }

  IconData _repeatingIcon() {
    return switch (_loopMode) {
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat,
    };
  }

  Color? _getRepeatingIconColor() {
    return _loopMode == LoopMode.off ? Colors.grey : ColorsApp.spotify;
  }

  void _setupRepeatOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }

    setState(() {
      _audioPlayManager.player.setLoopMode(_loopMode);
    });
  }
}
