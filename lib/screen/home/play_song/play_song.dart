import 'package:flutter/material.dart';
import 'package:music_app/screen/home/play_song/play_song_page.dart';

import '../../../data/model/song.dart';

class PlaySong extends StatelessWidget {
  const PlaySong({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return PlaySongPage(
      songs: songs,
      playingSong: playingSong,
    );
  }
}
