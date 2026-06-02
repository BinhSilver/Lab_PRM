import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Ex3Favorite(),
  ));
}

class FavoriteItem {
  final String name;
  final int number;
  bool isFavorite;

  FavoriteItem({
    required this.name,
    required this.number,
    this.isFavorite = false,
  });
}

class Ex3Favorite extends StatefulWidget {
  const Ex3Favorite({super.key});

  @override
  State<Ex3Favorite> createState() => _Ex3FavoriteState();
}

class _Ex3FavoriteState extends State<Ex3Favorite> {
  final List<FavoriteItem> _items = [
    FavoriteItem(name: 'LidTerm', number: 3),
    FavoriteItem(name: 'CraftRock', number: 4),
    FavoriteItem(name: 'BootClay', number: 5),
    FavoriteItem(name: 'CheckSuit', number: 6),
    FavoriteItem(name: 'TeamSake', number: 7),
    FavoriteItem(name: 'NewLaugh', number: 8),
    FavoriteItem(name: 'BlueCop', number: 9),
    FavoriteItem(name: 'WildTent', number: 10),
    FavoriteItem(name: 'SunFrost', number: 11),
    FavoriteItem(name: 'GoldLeaf', number: 12),
  ];

  void _toggleFavorite(int index) {
    setState(() {
      _items[index].isFavorite = !_items[index].isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Getting Started Testing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text(
              item.name,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${item.number}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            trailing: IconButton(
              icon: Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: item.isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () => _toggleFavorite(index),
            ),
          );
        },
      ),
    );
  }
}
