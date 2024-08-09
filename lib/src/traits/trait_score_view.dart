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
    final Map<String, Color> traitColors = {
      // Positive traits
      'compassionate': Colors.deepPurple.shade900,
      'honest': Colors.deepPurple.shade800,
      'courageous': Colors.deepPurple.shade300,
      'ambitious': Colors.deepPurple.shade400,
      'generous': Colors.deepPurple,
      'patient': Colors.deepPurple.shade900,
      'humble': Colors.deepPurple.shade800,
      'loyal': Colors.deepPurple.shade300,
      'optimistic': Colors.deepPurple.shade400,
      'responsible': Colors.deepPurple,

      // Negative traits
      'callous': Colors.deepOrange,
      'deceitful': Colors.deepOrange.shade400,
      'cowardly': Colors.deepOrange.shade300,
      'lazy': Colors.deepOrange.shade800,
      'greedy': Colors.deepOrange.shade900,
      'impatient': Colors.deepOrange,
      'arrogant': Colors.deepOrange.shade400,
      'disloyal': Colors.deepOrange.shade300,
      'pessimistic': Colors.deepOrange.shade800,
      'irresponsible': Colors.deepOrange.shade900,
    };
    Color _getTraitColor(String trait) {
      // Split the trait name if it's in the format "positive_negative"
      final traitParts = trait.split('_');
      final positiveTraitName = traitParts[0].toLowerCase();
      final negativeTraitName =
          traitParts.length > 1 ? traitParts[1].toLowerCase() : null;

      // Check if it's a positive trait
      if (traitColors.containsKey(positiveTraitName)) {
        return traitColors[positiveTraitName]!;
      }
      // Check if it's a negative trait
      else if (negativeTraitName != null &&
          traitColors.containsKey(negativeTraitName)) {
        return traitColors[negativeTraitName]!;
      }
      // Default color if not found
      else {
        return Colors.grey;
      }
    }

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
                color: _getTraitColor(traitName),
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
