import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'pages/dimension_page.dart';
import 'pages/game_page.dart';
import 'pages/game_over_page.dart';
import 'pages/shop_page.dart';
import 'bubble_colors_extension.dart';

final ValueNotifier<String> currentlyUsingNotifier = ValueNotifier('none');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  currentlyUsingNotifier.value = prefs.getString('currently_using') ?? 'none';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  ThemeData _getThemeDataForCurrentMode(String mode) {
    if (mode == 'dark_mode') {
      return ThemeData.dark().copyWith(
        extensions: [
          BubbleColors(
            bubbleColor: Colors.grey.shade800,
            selectedBubbleColor: Colors.orange,
            textColor: Colors.white,
          ),
        ],
      );
    } else if (mode == 'retro_mode') {
      return ThemeData.light().copyWith(
        primaryColor: Colors.brown,
        scaffoldBackgroundColor: Colors.brown.shade100,
        appBarTheme: AppBarTheme(color: Colors.brown.shade700),
        textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'Courier',
              bodyColor: Colors.brown.shade900,
              displayColor: Colors.brown.shade900,
            ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.brown,
          secondary: Colors.brown.shade300,
        ),
        extensions: [
          BubbleColors(
            bubbleColor: Colors.brown.shade200,
            selectedBubbleColor: Colors.brown.shade700,
            textColor: Colors.brown.shade900,
          ),
        ],
      );
    } else if (mode == 'neon_mode') {
      return ThemeData.dark().copyWith(
        primaryColor: Colors.pinkAccent,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.pinkAccent),
        colorScheme: const ColorScheme.dark(
          primary: Colors.pinkAccent,
          secondary: Colors.greenAccent,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.greenAccent,
              displayColor: Colors.greenAccent,
            ),
        extensions: [
          BubbleColors(
            bubbleColor: Colors.pinkAccent,
            selectedBubbleColor: Colors.greenAccent,
            textColor: Colors.greenAccent,
          ),
        ],
      );
    } else {
      // Default
      return ThemeData.light().copyWith(
        extensions: [
          BubbleColors(
            bubbleColor: Colors.blueAccent,
            selectedBubbleColor: Colors.orange,
            textColor: Colors.black,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: currentlyUsingNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Re: Word',
          theme: _getThemeDataForCurrentMode(mode),
          initialRoute: '/',
          routes: {
            '/': (context) => HomePage(
                  onRefreshTheme: () async {
                    final prefs = await SharedPreferences.getInstance();
                    currentlyUsingNotifier.value =
                        prefs.getString('currently_using') ?? 'none';
                  },
                ),
            '/dimensions': (context) => DimensionPage(),
            '/game': (context) => GamePage(),
            '/gameover': (context) => GameOverPage(),
            '/shop': (context) => ShopPage(),
          },
        );
      },
    );
  }
}
