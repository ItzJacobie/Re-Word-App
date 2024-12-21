import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onRefreshTheme;

  HomePage({required this.onRefreshTheme});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalPoints = 0;

  // A list of words we’ll fade in the background for texture
  // You can replace these with any words you like
  final List<String> fadedWords = [
    'WORD',
    'PUZZLE',
    'GAME',
    'FUN',
    'DRAG',
    'SWIPE',
    'ALPHABET',
    'BUBBLE'
  ];

  @override
  void initState() {
    super.initState();
    _loadTotalPoints();
  }

  Future<void> _loadTotalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalPoints = prefs.getInt('total_points') ?? 0;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // After navigation returns to Home, refresh theme if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onRefreshTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We remove the default appBar so we can control our own design
      body: Stack(
        children: [
          // 1) Background: repeated faint words
          _FadedWordsBackground(words: fadedWords),

          // 2) Foreground UI
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Points in the top right
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      'Points: $totalPoints',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Large title in the center top half
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Re: Word',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Buttons in the lower portion
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLargeButton(
                        label: 'Play',
                        onTap: () async {
                          await Navigator.pushNamed(context, '/dimensions');
                          _loadTotalPoints();
                        },
                      ),
                      SizedBox(height: 20),
                      _buildLargeButton(
                        label: 'Shop',
                        onTap: () async {
                          await Navigator.pushNamed(context, '/shop');
                          _loadTotalPoints();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // A helper method to build bigger, more stylish buttons
  Widget _buildLargeButton(
      {required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

/// A widget that places faint, randomly positioned words in the background.
class _FadedWordsBackground extends StatelessWidget {
  final List<String> words;
  final Random _random = Random();

  _FadedWordsBackground({required this.words});

  @override
  Widget build(BuildContext context) {
    // We’ll overlay these words multiple times, each at random position
    // and with random rotation, to create a textured pattern
    // Adjust count or styling as you like
    final int wordCount = 20;

    return LayoutBuilder(
      builder: (context, constraints) {
        List<Widget> positionedWords = [];
        for (int i = 0; i < wordCount; i++) {
          final word = words[_random.nextInt(words.length)];
          final left = _random.nextDouble() * constraints.maxWidth;
          final top = _random.nextDouble() * constraints.maxHeight;
          final rotation = _random.nextDouble() * 2 * pi; // random rotation
          final fontSize = 24 + _random.nextDouble() * 10; // 24 to 34
          final opacity = 0.05 + _random.nextDouble() * 0.05; // 0.05 to 0.1

          positionedWords.add(Positioned(
            left: left,
            top: top,
            child: Transform.rotate(
              angle: rotation,
              child: Text(
                word,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.black.withOpacity(opacity),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ));
        }

        return Container(
          // Full screen background
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Colors.white,
          child: Stack(
            children: positionedWords,
          ),
        );
      },
    );
  }
}
