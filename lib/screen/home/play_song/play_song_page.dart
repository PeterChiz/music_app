import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/utils/constants/sizes.dart';

import '../../../data/model/song.dart';
import 'audio_play_manager.dart';

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

  @override
  void initState() {
    _imageAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 12000));
    _audioPlayManager = AudioPlayManager(songUrl: widget.playingSong.source);
    _audioPlayManager.init();
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
              Text(widget.playingSong.album),
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
                    image: widget.playingSong.image,
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
                          Text(widget.playingSong.title),
                          const SizedBox(
                            height: SizesApp.spaceSongItems,
                          ),
                          Text(
                            widget.playingSong.artist,
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
                  bottom: 16,
                ),
                child: _progressBar(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 16,
                ),
                child: _mediaButtons(),
              ),
            ],
          ),
        ),
      ), //2
    );
  }

  Widget _mediaButtons(){
    return const SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(function: null, icon: Icons.shuffle, size: 24, color: Colors.deepPurple),
          MediaButtonControl(function: null, icon: Icons.skip_previous, size: 36, color: Colors.deepPurple),
          MediaButtonControl(function: null, icon: Icons.play_arrow_sharp, size: 48, color: Colors.deepPurple),
          MediaButtonControl(function: null, icon: Icons.skip_next, size: 36, color: Colors.deepPurple),
          MediaButtonControl(function: null, icon: Icons.repeat, size: 24, color: Colors.deepPurple),
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
          return ProgressBar(progress: progress, total: total);
        }); //5
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl(
      {super.key,
      required this.function,
      required this.icon,
      required this.size,
      required this.color});

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<MediaButtonControl> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
