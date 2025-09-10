import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Osemsmerovka',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PuzzleScreen(),
    );
  }
}

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final int gridSize = 12;
  final List<String> words = [
    "DOM",
    "MAMA",
    "AUTO",
    "LES",
    "PES",
    "SKOLA",
    "KNIHA",
    "VODA"
  ];
  final String hiddenText = "Život je krásny, keď sa hráš 😊";

  late List<List<String>> grid;
  late List<Offset> selectedCells;
  Color highlightColor = Colors.red.withOpacity(0.4);

  @override
  void initState() {
    super.initState();
    grid = _generateGrid(gridSize, words);
    selectedCells = [];
  }

  List<List<String>> _generateGrid(int size, List<String> words) {
    List<List<String>> grid =
        List.generate(size, (_) => List.generate(size, (_) => ''));
    Random random = Random();

    List<Offset> directions = [
      const Offset(1, 0),
      const Offset(-1, 0),
      const Offset(0, 1),
      const Offset(0, -1),
      const Offset(1, 1),
      const Offset(-1, -1),
      const Offset(1, -1),
      const Offset(-1, 1),
    ];

    for (var word in words) {
      bool placed = false;
      while (!placed) {
        int row = random.nextInt(size);
        int col = random.nextInt(size);
        Offset dir = directions[random.nextInt(directions.length)];
        int endRow = row + (word.length - 1) * dir.dy.toInt();
        int endCol = col + (word.length - 1) * dir.dx.toInt();

        if (endRow < 0 || endRow >= size || endCol < 0 || endCol >= size) {
          continue;
        }

        bool canPlace = true;
        for (int i = 0; i < word.length; i++) {
          int r = row + i * dir.dy.toInt();
          int c = col + i * dir.dx.toInt();
          if (grid[r][c] != '' && grid[r][c] != word[i]) {
            canPlace = false;
            break;
          }
        }

        if (canPlace) {
          for (int i = 0; i < word.length; i++) {
            int r = row + i * dir.dy.toInt();
            int c = col + i * dir.dx.toInt();
            grid[r][c] = word[i];
          }
          placed = true;
        }
      }
    }

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == '') {
          grid[r][c] = String.fromCharCode(random.nextInt(26) + 65);
        }
      }
    }

    return grid;
  }

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    setState(() {
      selectedCells = [_positionToCell(details.localPosition, constraints)];
    });
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    setState(() {
      selectedCells.add(_positionToCell(details.localPosition, constraints));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      selectedCells = [];
    });
  }

  Offset _positionToCell(Offset position, BoxConstraints constraints) {
    double cellSize = constraints.maxWidth / gridSize;
    int row = (position.dy ~/ cellSize).clamp(0, gridSize - 1);
    int col = (position.dx ~/ cellSize).clamp(0, gridSize - 1);
    return Offset(row.toDouble(), col.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Osemsmerovka")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    Color tempColor = highlightColor;
                    return AlertDialog(
                      title: const Text('Vyber farbu zvýraznenia'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: highlightColor,
                          onColorChanged: (color) {
                            tempColor = color.withOpacity(0.4);
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Zrušiť'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            setState(() {
                              highlightColor = tempColor;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text("Vyber farbu zvýraznenia"),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanStart: (details) => _onPanStart(details, constraints),
                  onPanUpdate: (details) => _onPanUpdate(details, constraints),
                  onPanEnd: _onPanEnd,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      int row = index ~/ gridSize;
                      int col = index % gridSize;
                      bool isSelected = selectedCells.any(
                          (cell) => cell.dx.toInt() == row && cell.dy.toInt() == col);

                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? highlightColor : Colors.transparent,
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(
                          grid[row][col],
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Skrytý text: $hiddenText",
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}