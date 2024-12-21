import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // to access currentlyUsingNotifier

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int totalPoints = 0;

  bool darkModePurchased = false;
  bool retroModePurchased = false;
  bool neonModePurchased = false;

  String currentlyUsing = 'none';

  final int darkModeCost = 50;
  final int retroModeCost = 60;
  final int neonModeCost = 70;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalPoints = prefs.getInt('total_points') ?? 0;
      darkModePurchased = prefs.getBool('dark_mode_purchased') ?? false;
      retroModePurchased = prefs.getBool('retro_mode_purchased') ?? false;
      neonModePurchased = prefs.getBool('neon_mode_purchased') ?? false;
      currentlyUsing = prefs.getString('currently_using') ?? 'none';
    });
  }

  Future<void> _savePurchases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_points', totalPoints);
    await prefs.setBool('dark_mode_purchased', darkModePurchased);
    await prefs.setBool('retro_mode_purchased', retroModePurchased);
    await prefs.setBool('neon_mode_purchased', neonModePurchased);
    await prefs.setString('currently_using', currentlyUsing);

    // Update the global notifier to instantly reflect changes
    currentlyUsingNotifier.value = currentlyUsing;
  }

  Future<void> _purchaseItem(String item, int cost) async {
    if (totalPoints >= cost) {
      totalPoints -= cost;
      if (item == 'dark_mode') darkModePurchased = true;
      if (item == 'retro_mode') retroModePurchased = true;
      if (item == 'neon_mode') neonModePurchased = true;
      await _savePurchases();
      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Purchase successful!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Not enough points.')));
    }
  }

  Future<void> _useItem(String item) async {
    currentlyUsing = item;
    await _savePurchases();
    setState(() {});
    // Theme changes immediately due to currentlyUsingNotifier update
  }

  Future<void> _stopUsing() async {
    currentlyUsing = 'none';
    await _savePurchases();
    setState(() {});
    // Theme reverts to default
  }

  String _getButtonText(String item, bool purchased) {
    if (!purchased) return 'Buy';
    if (currentlyUsing == item) return 'Using';
    return 'Use';
  }

  Future<void> _onButtonPressed(String item, bool purchased, int cost) async {
    String buttonText = _getButtonText(item, purchased);
    if (buttonText == 'Buy') {
      await _purchaseItem(item, cost);
    } else if (buttonText == 'Use') {
      await _useItem(item);
      // Don't navigate away, user can see theme changes instantly
    } else if (buttonText == 'Using') {
      await _stopUsing();
    }
  }

  Future<void> _refundPurchases() async {
    int refundAmount = 0;
    if (darkModePurchased) refundAmount += darkModeCost;
    if (retroModePurchased) refundAmount += retroModeCost;
    if (neonModePurchased) refundAmount += neonModeCost;

    darkModePurchased = false;
    retroModePurchased = false;
    neonModePurchased = false;
    currentlyUsing = 'none';
    totalPoints += refundAmount;

    await _savePurchases();
    setState(() {});
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('All purchases refunded!')));
    // Theme updates to default instantly
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop (Points: $totalPoints)'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // Going back will still show correct theme, but we already update theme instantly.
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildShopItem(
                  item: 'dark_mode',
                  title: 'Dark Mode',
                  description: 'Enable a dark theme',
                  cost: darkModeCost,
                  purchased: darkModePurchased,
                ),
                SizedBox(height: 16),
                _buildShopItem(
                  item: 'retro_mode',
                  title: 'Retro Mode',
                  description: 'Old-school sepia look',
                  cost: retroModeCost,
                  purchased: retroModePurchased,
                ),
                SizedBox(height: 16),
                _buildShopItem(
                  item: 'neon_mode',
                  title: 'Neon Mode',
                  description: 'Bright neon colors',
                  cost: neonModeCost,
                  purchased: neonModePurchased,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: _refundPurchases,
              child: Text('Refund Purchases'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem({
    required String item,
    required String title,
    required String description,
    required int cost,
    required bool purchased,
  }) {
    String buttonText = _getButtonText(item, purchased);

    Color buttonColor;
    if (buttonText == 'Buy') {
      buttonColor = Colors.blue;
    } else if (buttonText == 'Use') {
      buttonColor = Colors.green;
    } else {
      // 'Using'
      buttonColor = Colors.orange;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(description),
                  SizedBox(height: 8),
                  Text('Cost: $cost points', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(foregroundColor: buttonColor),
              onPressed: () => _onButtonPressed(item, purchased, cost),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
