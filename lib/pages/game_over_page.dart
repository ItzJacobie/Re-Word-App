import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameOverPage extends StatefulWidget {
  @override
  _GameOverPageState createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage> {
  List<String> wordsFound = [];
  int finalScore = 0;
  List<String> foundByUser = [];

  bool _scoreUpdated = false; // To ensure we only update score once

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      wordsFound = (args['words'] as List<dynamic>?)
              ?.map((w) => w.toString())
              .toList() ??
          [];
      finalScore = args['score'] ?? 0;
      foundByUser = (args['foundByUser'] as List<dynamic>?)
              ?.map((w) => w.toString())
              .toList() ??
          [];
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScoreOnce();
    });
  }

  Future<void> _updateScoreOnce() async {
    if (!_scoreUpdated && finalScore > 0) {
      _scoreUpdated = true; // Prevent double updates
      final prefs = await SharedPreferences.getInstance();
      int currentPoints = prefs.getInt('total_points') ?? 0;
      currentPoints += finalScore;
      await prefs.setInt('total_points', currentPoints);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Over'),
      ),
      body: Column(
        children: [
          Text(
            'Final Score: $finalScore',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Possible Words:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: wordsFound.length,
              itemBuilder: (context, index) {
                String word = wordsFound[index];
                bool userFoundThisWord =
                    foundByUser.contains(word.toLowerCase());

                return ListTile(
                  title: Text(
                    word,
                    style: TextStyle(
                      fontSize: 18,
                      decoration: userFoundThisWord
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Text('Return to Home'),
          ),
        ],
      ),
    );
  }
}
