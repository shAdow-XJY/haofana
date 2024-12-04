import 'package:flutter/material.dart';

import 'HFA/HFAForestFireIceGame.dart';
import 'HFA/HFAMatchThreeGame.dart';
import 'HFA/HFAPandaIncenseGame.dart';
import 'HFA/HFAShooterGame.dart';
import 'HFA/HFAWatermelonGame.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 当前显示的页面索引
  int _currentIndex = 0;

  // 页面信息列表：包含页面、标题和图标
  final List<PageInfo> _pages = [
    PageInfo(const MatchThreeGame(), 'Match Three Game', Icons.gamepad),
    PageInfo(const ForestFireIceGame(), 'Forest Fire Ice Game', Icons.local_fire_department),
    PageInfo(const ShooterGame(), 'Shooter Game', Icons.control_point),
    PageInfo(const WatermelonGame(), 'Watermelon Game', Icons.apple),
    PageInfo(const PandaIncenseGame(), 'Panda Incense Game', Icons.catching_pokemon),
    PageInfo(const Center(child: Text('Settings Page', style: TextStyle(fontSize: 24))), 'Settings', Icons.settings),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _currentIndex = _pages.length - 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Side Menu Navigation"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "fan si ren",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Select a page",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // 动态生成 ListTile
            ..._pages.map((pageInfo) => ListTile(
              leading: Icon(pageInfo.icon),
              title: Text(pageInfo.title),
              onTap: () {
                setState(() {
                  _currentIndex = _pages.indexOf(pageInfo);
                });
                Navigator.pop(context); // 关闭抽屉
              },
            )).toList(),
          ],
        ),
      ),
      body: _pages[_currentIndex].page, // 根据当前索引显示页面
    );
  }
}

// 页面信息的封装类
class PageInfo {
  final Widget page;
  final String title;
  final IconData icon;

  PageInfo(this.page, this.title, this.icon);
}