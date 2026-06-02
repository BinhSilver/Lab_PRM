import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Ex2ListView(),
  ));
}

class Ex2ListView extends StatelessWidget {
  const Ex2ListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ex2: ListView')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          final isEven = index % 2 == 0;
          return Container(
            color: isEven ? const Color(0xFFB0D4E8) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Text(
              'Item ${index + 1}',
              style: const TextStyle(fontSize: 15),
            ),
          );
        },
      ),
    );
  }
}
