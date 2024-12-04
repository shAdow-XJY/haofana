import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ShooterGame extends StatefulWidget {
  const ShooterGame({super.key});

  @override
  _ShooterGameState createState() => _ShooterGameState();
}

class _ShooterGameState extends State<ShooterGame> {
  double targetX = 100; // 目标X位置
  double targetY = 100; // 目标Y位置
  double targetSize = 50; // 目标大小
  double targetSpeedX = 3; // 目标水平速度
  double targetSpeedY = 3; // 目标垂直速度
  int score = 0; // 玩家得分
  int timeLeft = 30; // 游戏剩余时间（秒）
  bool gameRunning = true; // 游戏是否进行中
  late Timer gameTimer; // 倒计时计时器
  late Timer movementTimer; // 移动计时器

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    // 初始化游戏状态
    score = 0;
    timeLeft = 30;
    gameRunning = true;

    // 启动目标移动
    movementTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (!gameRunning) return;
      setState(() {
        targetX += targetSpeedX;
        targetY += targetSpeedY;

        // 检测边界反弹
        if (targetX <= 0 || targetX + targetSize >= MediaQuery.of(context).size.width) {
          targetSpeedX = -targetSpeedX;
        }
        if (targetY <= 0 || targetY + targetSize >= MediaQuery.of(context).size.height) {
          targetSpeedY = -targetSpeedY;
        }
      });
    });

    // 启动游戏倒计时
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!gameRunning) return;
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          gameRunning = false;
          gameTimer.cancel();
          movementTimer.cancel();
        }
      });
    });
  }

  void onShoot(double x, double y) {
    if (!gameRunning) return;

    // 检测是否命中目标
    if (x >= targetX &&
        x <= targetX + targetSize &&
        y >= targetY &&
        y <= targetY + targetSize) {
      setState(() {
        score += 10; // 命中加分
        // 随机重置目标位置
        targetX = Random().nextDouble() *
            (MediaQuery.of(context).size.width - targetSize);
        targetY = Random().nextDouble() *
            (MediaQuery.of(context).size.height - targetSize);
      });
    }
  }

  @override
  void dispose() {
    gameTimer.cancel();
    movementTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final tapPosition = details.localPosition;
          onShoot(tapPosition.dx, tapPosition.dy);
        },
        child: Stack(
          children: [
            // 显示得分
            Positioned(
              top: 40,
              left: 20,
              child: Text(
                "Score: $score",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // 显示时间
            Positioned(
              top: 80,
              left: 20,
              child: Text(
                "Time Left: $timeLeft s",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // 目标
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: TargetPainter(
                targetX: targetX,
                targetY: targetY,
                targetSize: targetSize,
              ),
            ),
            // 游戏结束提示
            if (!gameRunning)
              Center(
                child: Text(
                  "Game Over\nYour Score: $score",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 32),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TargetPainter extends CustomPainter {
  final double targetX;
  final double targetY;
  final double targetSize;

  TargetPainter({
    required this.targetX,
    required this.targetY,
    required this.targetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red;

    // 绘制目标
    canvas.drawCircle(
      Offset(targetX + targetSize / 2, targetY + targetSize / 2),
      targetSize / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}