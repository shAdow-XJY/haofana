import 'dart:math';
import 'package:flutter/material.dart';

class MatchThreeGame extends StatefulWidget {
  const MatchThreeGame({super.key});

  @override
  _MatchThreeGameState createState() => _MatchThreeGameState();
}

class _MatchThreeGameState extends State<MatchThreeGame> {
  static const int gridSize = 8; // 棋盘大小
  static const int numColors = 5; // 方块种类数
  late List<List<int>> grid; // 棋盘
  int score = 0; // 分数
  List<int>? selectedTile; // 被点击的方块坐标

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  // 初始化棋盘
  void resetGame() {
    grid = List.generate(
      gridSize,
          (_) => List.generate(gridSize, (_) => Random().nextInt(numColors)),
    );
    while (findMatches().isNotEmpty) {
      grid = List.generate(
        gridSize,
            (_) => List.generate(gridSize, (_) => Random().nextInt(numColors)),
      );
    }
    setState(() {
      score = 0;
      selectedTile = null;
    });
  }

  // 查找匹配的方块
  List<List<int>> findMatches() {
    List<List<int>> matches = [];
    // 检查横向
    for (int row = 0; row < gridSize; row++) {
      int startCol = 0;
      while (startCol < gridSize) {
        int endCol = startCol;
        while (endCol < gridSize - 1 &&
            grid[row][endCol] != -1 &&
            grid[row][endCol] == grid[row][endCol + 1]) {
          endCol++;
        }
        if (endCol - startCol + 1 >= 3) {
          for (int col = startCol; col <= endCol; col++) {
            matches.add([row, col]);
          }
        }
        startCol = endCol + 1;
      }
    }

    // 检查纵向
    for (int col = 0; col < gridSize; col++) {
      int startRow = 0;
      while (startRow < gridSize) {
        int endRow = startRow;
        while (endRow < gridSize - 1 &&
            grid[endRow][col] != -1 &&
            grid[endRow][col] == grid[endRow + 1][col]) {
          endRow++;
        }
        if (endRow - startRow + 1 >= 3) {
          for (int row = startRow; row <= endRow; row++) {
            matches.add([row, col]);
          }
        }
        startRow = endRow + 1;
      }
    }
    return matches;
  }

// 处理匹配的方块
  void handleMatches() {
    List<List<int>> matches = findMatches();
    if (matches.isEmpty) return;

    setState(() {
      for (var match in matches) {
        int row = match[0];
        int col = match[1];
        grid[row][col] = -1; // 标记为空
      }
      score += matches.length * 10; // 每个匹配增加分数
    });

    // 下落并补充空位
    Future.delayed(Duration(milliseconds: 200), () {
      dropTiles();
      refillGrid();
      handleMatches(); // 递归处理新的匹配
    });
  }

  // 让方块下落
  void dropTiles() {
    for (int col = 0; col < gridSize; col++) {
      List<int> column = [];
      for (int row = 0; row < gridSize; row++) {
        if (grid[row][col] != -1) {
          column.add(grid[row][col]);
        }
      }
      while (column.length < gridSize) {
        column.insert(0, -1); // 在顶部插入空位
      }
      for (int row = 0; row < gridSize; row++) {
        grid[row][col] = column[row];
      }
    }
  }

  // 补充新的方块
  void refillGrid() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] == -1) {
          grid[row][col] = Random().nextInt(numColors);
        }
      }
    }
  }

  // 交换两个方块
  void swapTiles(int row1, int col1, int row2, int col2) {
    setState(() {
      int temp = grid[row1][col1];
      grid[row1][col1] = grid[row2][col2];
      grid[row2][col2] = temp;
    });

    Future.delayed(Duration(milliseconds: 200), () {
      if (findMatches().isEmpty) {
        // 没有匹配则还原交换
        setState(() {
          int temp = grid[row1][col1];
          grid[row1][col1] = grid[row2][col2];
          grid[row2][col2] = temp;
        });
      } else {
        handleMatches(); // 有匹配则处理
      }
    });
  }

  // 点击处理逻辑
  void handleTap(int row, int col) {
    if (selectedTile == null) {
      setState(() {
        selectedTile = [row, col]; // 记录首次点击的方块
      });
    } else {
      int prevRow = selectedTile![0];
      int prevCol = selectedTile![1];

      // 如果点击的方块相邻，尝试交换
      if ((prevRow == row && (prevCol - col).abs() == 1) ||
          (prevCol == col && (prevRow - row).abs() == 1)) {
        swapTiles(prevRow, prevCol, row, col);
      }

      setState(() {
        selectedTile = null; // 重置选择
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("消消乐小游戏"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // 显示分数
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "分数: $score",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // 棋盘
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                int row = index ~/ gridSize;
                int col = index % gridSize;
                bool isSelected =
                    selectedTile != null &&
                        selectedTile![0] == row &&
                        selectedTile![1] == col;
                return GestureDetector(
                  onTap: () => handleTap(row, col),
                  child: Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: grid[row][col] == -1
                          ? Colors.grey
                          : Colors.primaries[grid[row][col]],
                      border: isSelected
                          ? Border.all(color: Colors.yellow, width: 3)
                          : null,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}