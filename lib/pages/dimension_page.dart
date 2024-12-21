import 'package:flutter/material.dart';

/// DIMENSION PAGE
/// Choose 3x3 or 4x4 grid.
/// Also a back button to go back to HomePage.
class DimensionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Grid Size'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // back to Home
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('3x3'),
              onPressed: () {
                Navigator.pushNamed(context, '/game', arguments: 3);
              },
            ),
            ElevatedButton(
              child: Text('4x4'),
              onPressed: () {
                Navigator.pushNamed(context, '/game', arguments: 4);
              },
            ),
          ],
        ),
      ),
    );
  }
}
