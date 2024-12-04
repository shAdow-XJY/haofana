import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math'; // 用于生成随机位置
import 'package:flutter/services.dart';

class ForestFireIceGame extends StatefulWidget {
  const ForestFireIceGame({super.key});

  @override
  _ForestFireIceGameState createState() => _ForestFireIceGameState();
}

class _ForestFireIceGameState extends State<ForestFireIceGame> {
  double fireX = -0.5; // 火人初始X坐标
  double iceX = 0.5; // 冰人初始X坐标
  double itemY = -1.0; // 掉落物品的Y坐标
  double itemX = 0.0; // 掉落物品的X坐标
  String itemType = 'fire'; // 掉落物品类型：'fire' 或 'ice'
  bool gameRunning = true; // 游戏状态
  int score = 0; // 玩家得分

  late Timer _gameLoop;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    _gameLoop = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!gameRunning) {
        timer.cancel();
        return;
      }
      setState(() {
        // 让物品下落
        itemY += 0.02;

        // 重置物品
        if (itemY > 1.0) {
          resetItem();
        }

        // 检测碰撞
        if ((fireX - itemX).abs() < 0.2 && itemY > 0.8 && itemType == 'fire') {
          score++;
          resetItem();
        } else if ((iceX - itemX).abs() < 0.2 && itemY > 0.8 && itemType == 'ice') {
          score++;
          resetItem();
        }
      });
    });
  }

  void resetItem() {
    itemY = -1.0;
    itemX = Random().nextDouble() * 2 - 1; // 随机X位置 (-1到1)
    itemType = Random().nextBool() ? 'fire' : 'ice'; // 随机物品类型
  }

  void moveCharacter(String character, String direction) {
    setState(() {
      if (character == 'fire') {
        if (direction == 'left' && fireX > -1) fireX -= 0.1;
        if (direction == 'right' && fireX < 1) fireX += 0.1;
      } else if (character == 'ice') {
        if (direction == 'left' && iceX > -1) iceX -= 0.1;
        if (direction == 'right' && iceX < 1) iceX += 0.1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          // 火人（WASD 控制）
          if (event.logicalKey == LogicalKeyboardKey.keyA) {
            moveCharacter('fire', 'left');
          } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
            moveCharacter('fire', 'right');
          }
          // 冰人（方向键控制）
          else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            moveCharacter('ice', 'left');
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            moveCharacter('ice', 'right');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 分数显示
            Positioned(
              top: 50,
              left: 20,
              child: Text(
                'Score: $score',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // 游戏内容
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Container(
                  color: Colors.green[900],
                  child: CustomPaint(
                    painter: GamePainter(
                      fireX: fireX,
                      iceX: iceX,
                      itemX: itemX,
                      itemY: itemY,
                      itemType: itemType,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameLoop.cancel();
    super.dispose();
  }
}

class GamePainter extends CustomPainter {
  final double fireX;
  final double iceX;
  final double itemX;
  final double itemY;
  final String itemType;

  GamePainter({
    required this.fireX,
    required this.iceX,
    required this.itemX,
    required this.itemY,
    required this.itemType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    // 画火人
    paint.color = Colors.red;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(fireX * size.width / 2, size.height * 0.9),
        width: size.width * 0.1,
        height: size.height * 0.1,
      ),
      paint,
    );

    // 画冰人
    paint.color = Colors.blue;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(iceX * size.width / 2, size.height * 0.9),
        width: size.width * 0.1,
        height: size.height * 0.1,
      ),
      paint,
    );

    // 画掉落物品
    paint.color = itemType == 'fire' ? Colors.orange : Colors.cyan;
    canvas.drawCircle(
      Offset(itemX * size.width / 2, itemY * size.height),
      size.width * 0.05,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}