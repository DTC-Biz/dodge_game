import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final dummyRanks = [
      {'rank': 1, 'name': 'P**k', 'score': 24580},
      {'rank': 2, 'name': 'K**m', 'score': 19200},
      {'rank': 3, 'name': 'L**e', 'score': 17900},
      {'rank': 4, 'name': 'C**i', 'score': 15440},
      {'rank': 5, 'name': 'J**n', 'score': 13770},
    ];
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(backgroundColor: AppTheme.background, foregroundColor: Colors.white, title: const Text('글로벌 순위'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: dummyRanks.length,
        separatorBuilder: (_, __) => const Divider(color: Color(0xFF1A1A1A), height: 1),
        itemBuilder: (context, i) {
          final item = dummyRanks[i];
          final rank = item['rank'] as int;
          final name = item['name'] as String;
          final score = item['score'] as int;
          Color rankColor = Colors.grey;
          if (rank == 1) rankColor = const Color(0xFFFAC775);
          if (rank == 2) rankColor = const Color(0xFFB4B2A9);
          if (rank == 3) rankColor = const Color(0xFFF5C4B3);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              SizedBox(width: 36, child: Text('$rank', style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, fontSize: 16))),
              Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 15))),
              Text('$score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ]),
          );
        },
      ),
    );
  }
}
