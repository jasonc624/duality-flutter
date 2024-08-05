import 'package:flutter/material.dart';

class TraitScoreView extends StatelessWidget {
  final String trait;
  final dynamic score;
  final String reason;

  const TraitScoreView({
    Key? key,
    required this.trait,
    required int this.score,
    required String this.reason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPositive = _isPositiveScore(score);
    String traitName = trait
        .split('_')
        .asMap()
        .entries
        .map((entry) {
          int idx = entry.key;
          String word = entry.value;
          if (isPositive) {
            return idx == 0 ? word.capitalize() : '';
          } else {
            return idx == 1 ? word.capitalize() : '';
          }
        })
        .where((word) => word.isNotEmpty)
        .join(' ');
    String scoreText = _formatScore(score);

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              traitName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $scoreText',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              reason,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPositiveScore(dynamic score) {
    if (score is int) {
      return score > 0;
    } else if (score is List) {
      return score.isNotEmpty && score[0] > 0;
    }
    return false;
  }

  String _formatScore(dynamic score) {
    if (score is int) {
      return score.toString();
    } else if (score is List) {
      return score.join(', ');
    }
    return 'N/A';
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
