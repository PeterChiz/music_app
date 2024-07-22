import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:music_app/utils/constants/colors.dart';
import 'package:music_app/screen/home/home.dart';
import 'package:music_app/screen/search/search.dart';
import 'package:music_app/screen/profile/profile.dart';
import 'package:music_app/screen/setting/setting.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng nghe nhạc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorsApp.spotify,
        ),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatelessWidget {
  const MusicHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const HomeScreen(),
      const SearchScreen(),
      const ProfileScreen(),
      const SettingScreen(),
    ];

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.play_circle), label: 'Chơi'),
          BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Tìm kiếm'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (context) => tabs[index],
        );
      },
    );
  }
}