import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../widgets/line_painter.dart';
import '../bubble_colors_extension.dart'; // or wherever you define your theme extension

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int gridSize = 3;
  List<String> letters = [];
  List<List<String>> grid = [];

  final GlobalKey _gridKey = GlobalKey();

  List<int> visitedCells = [];
  String currentWord = '';

  double cellWidth = 0;
  double cellHeight = 0;
  double bubbleRadius = 0;
  double spacing = 0;
  Offset? currentDragPosition;

  Timer? _timer;
  int _remainingSeconds = 60;

  int score = 0;

  static Set<String>? dictionary;

  final List<List<int>> directions = [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1]
  ];

  /// Which words the user has actually found/scored
  Set<String> foundByUser = {};

  /// All possible words precomputed for this grid
  late List<String> _allPossibleWords;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      gridSize = args;
    }
    letters = _generateLetterGrid(gridSize);

    // Build the 2D grid from letters
    grid = [];
    for (int i = 0; i < gridSize; i++) {
      grid.add(letters.sublist(i * gridSize, (i + 1) * gridSize));
    }

    spacing = (gridSize == 3) ? 8 : 16;
  }

  @override
  void initState() {
    super.initState();
    _loadDictionary().then((_) {
      // Once dictionary is loaded, compute all possible words
      _allPossibleWords = _findAllWords(grid);
      // Then start the timer
      _startTimer();
    });
  }

  Future<void> _loadDictionary() async {
    if (dictionary == null) {
      String data = await rootBundle.loadString('assets/cleanedlist.txt');
      dictionary = data
          .split('\n')
          .map((w) => w.trim().toLowerCase())
          .where((w) => w.isNotEmpty)
          .toSet();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _navigateToGameOver(didWin: false);
        }
      });
    });
  }

  void _navigateToGameOver({required bool didWin}) {
    // Cancel timer if not already done
    _timer?.cancel();
    // Sort the list of all possible words for display
    final sortedAllWords = List<String>.from(_allPossibleWords)..sort();

    Navigator.pushReplacementNamed(context, '/gameover', arguments: {
      'words': sortedAllWords,
      'score': score,
      'foundByUser': foundByUser.toList(),
      'didWin': didWin,
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<String> _generateLetterGrid(int size) {
    final rand = Random();

    const vowels = ['A', 'E', 'I', 'O', 'U'];
    List<String> alphabet =
        List.generate(26, (i) => String.fromCharCode(65 + i));
    Set<String> vowelSet = vowels.toSet();
    final consonants = alphabet.where((ch) => !vowelSet.contains(ch)).toList();

    int gridCount = size * size;

    int minVowels, maxVowels;
    if (size == 3) {
      minVowels = 2;
      maxVowels = 3;
    } else if (size == 4) {
      minVowels = 4;
      maxVowels = 5;
    } else {
      minVowels = (gridCount / 4).floor();
      maxVowels = minVowels + 1;
    }

    int vowelCount = rand.nextInt(maxVowels - minVowels + 1) + minVowels;

    List<String> result = List.filled(gridCount, '');
    List<int> positions = List.generate(gridCount, (i) => i);
    positions.shuffle(rand);

    for (int i = 0; i < vowelCount; i++) {
      result[positions[i]] = vowels[rand.nextInt(vowels.length)];
    }
    for (int i = vowelCount; i < gridCount; i++) {
      result[positions[i]] = consonants[rand.nextInt(consonants.length)];
    }

    return result;
  }

  bool _isAdjacent(int lastCell, int newCell) {
    int lastRow = lastCell ~/ gridSize;
    int lastCol = lastCell % gridSize;

    int newRow = newCell ~/ gridSize;
    int newCol = newCell % gridSize;

    return (newRow - lastRow).abs() <= 1 && (newCol - lastCol).abs() <= 1;
  }

  Offset _cellCenter(int index) {
    int row = index ~/ gridSize;
    int col = index % gridSize;
    double x = col * (cellWidth + spacing);
    double y = row * (cellHeight + spacing);

    return Offset(x + cellWidth / 2, y + cellHeight / 2);
  }

  int? _getBubbleIndexFromOffset(Offset offset) {
    int col = (offset.dx ~/ (cellWidth + spacing));
    int row = (offset.dy ~/ (cellHeight + spacing));

    if (col < 0 || col >= gridSize || row < 0 || row >= gridSize) {
      return null;
    }
    int index = row * gridSize + col;

    Offset center = _cellCenter(index);
    double dx = offset.dx - center.dx;
    double dy = offset.dy - center.dy;
    double dist = sqrt(dx * dx + dy * dy);

    if (dist <= bubbleRadius) {
      return index;
    }
    return null;
  }

  void _onPanStart(DragStartDetails details) {
    final renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPos = renderBox.globalToLocal(details.globalPosition);
    currentDragPosition = localPos;

    final cellIndex = _getBubbleIndexFromOffset(localPos);
    if (cellIndex != null) {
      setState(() {
        visitedCells.clear();
        visitedCells.add(cellIndex);
        currentWord = letters[cellIndex];
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPos = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      currentDragPosition = localPos;
    });

    final cellIndex = _getBubbleIndexFromOffset(localPos);
    if (cellIndex != null && visitedCells.isNotEmpty) {
      int lastCell = visitedCells.last;
      if (cellIndex != lastCell && _isAdjacent(lastCell, cellIndex)) {
        if (!visitedCells.contains(cellIndex)) {
          setState(() {
            visitedCells.add(cellIndex);
            currentWord += letters[cellIndex];
          });
        }
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    String lowerWord = currentWord.toLowerCase();
    if (currentWord.length > 1 && dictionary!.contains(lowerWord)) {
      if (!foundByUser.contains(lowerWord)) {
        setState(() {
          foundByUser.add(lowerWord);
          score += currentWord.length;
        });
        // Check if user found all possible words
        if (foundByUser.length == _allPossibleWords.length) {
          _navigateToGameOver(didWin: true);
          return; // Stop here
        }
      }
    }

    setState(() {
      currentDragPosition = null;
      visitedCells.clear();
      currentWord = '';
    });
  }

  List<String> _findAllWords(List<List<String>> grid) {
    Set<String> foundWords = {};
    final dict = dictionary!;
    int rows = grid.length;
    int cols = grid[0].length;

    List<List<bool>> visited =
        List.generate(rows, (_) => List.filled(cols, false));

    void dfs(int r, int c, String wordSoFar) {
      String lower = wordSoFar.toLowerCase();
      if (wordSoFar.length > 1 && dict.contains(lower)) {
        foundWords.add(lower);
      }
      for (var dir in directions) {
        int nr = r + dir[0];
        int nc = c + dir[1];
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && !visited[nr][nc]) {
          visited[nr][nc] = true;
          dfs(nr, nc, wordSoFar + grid[nr][nc]);
          visited[nr][nc] = false;
        }
      }
    }

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        visited[r][c] = true;
        dfs(r, c, grid[r][c]);
        visited[r][c] = false;
      }
    }
    return foundWords.toList();
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColors = Theme.of(context).extension<BubbleColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Game | $_remainingSeconds s left | Score: $score'),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(
              currentWord,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: bubbleColors.textColor),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final totalHeight = constraints.maxHeight;

                double totalSpacingWidth = spacing * (gridSize - 1);
                double totalSpacingHeight = spacing * (gridSize - 1);

                double usableWidth = totalWidth - totalSpacingWidth;
                double usableHeight = totalHeight - totalSpacingHeight;

                cellWidth = usableWidth / gridSize;
                cellHeight = usableHeight / gridSize;

                if (gridSize == 3) {
                  bubbleRadius = min(cellWidth, cellHeight) * 0.4;
                } else if (gridSize == 4) {
                  bubbleRadius = min(cellWidth, cellHeight) * 0.3;
                }

                return GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Stack(
                    key: _gridKey,
                    children: [
                      CustomPaint(
                        size: Size(totalWidth, totalHeight),
                        painter: LinePainter(
                          visitedCells: visitedCells,
                          cellCenter: _cellCenter,
                          currentDragPosition: currentDragPosition,
                          lineColor: bubbleColors.selectedBubbleColor,
                        ),
                      ),
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: gridSize * gridSize,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: cellWidth / cellHeight,
                        ),
                        itemBuilder: (context, index) {
                          bool isSelected = visitedCells.contains(index);
                          return Center(
                            child: Container(
                              width: bubbleRadius * 2,
                              height: bubbleRadius * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? bubbleColors.selectedBubbleColor
                                    : bubbleColors.bubbleColor,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                letters[index],
                                style: TextStyle(
                                  fontSize: bubbleRadius * 0.9,
                                  color: bubbleColors.textColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
