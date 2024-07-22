import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/screen/home/play_song/play_song.dart';
import 'package:music_app/screen/home/view_model.dart';
import 'package:music_app/utils/constants/colors.dart';

import '../../data/model/song.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({super.key});

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  List<Song> songs = [];
  late ViewModelApp _viewModelApp;

  @override
  void initState() {
    _viewModelApp = ViewModelApp();
    _viewModelApp.loadSongs();
    observeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  //dùng dispose để giải phóng stream
  @override
  void dispose() {
    _viewModelApp.songStream.close();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.green,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return _SongItemSection(
      parent: this,
      song: songs[index],
    );
  }

  //lấy dữ liệu trong stream
  void observeData() {
    _viewModelApp.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Container(
              height: 400,
              color: ColorsApp.spotify,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Cài đặt'),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng cài đặt'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void navigate(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return PlaySong(
        songs: songs,
        playingSong: song,
      );
    }));
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.parent,
    required this.song,
  });

  final _HomeScreenPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 24, right: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          //hiển thị ảnh
          placeholder: 'assets/images/music_loading.png',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/music_loading.png',
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        onPressed: () {
          parent.showBottomSheet();
        },
        icon: const Icon(Icons.more_horiz),
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}
