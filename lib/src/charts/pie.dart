import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

enum TraitType { all, positive, negative }

class TraitScoresPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> behaviorEntries;
  final TraitType traitType;
  final String title;

  const TraitScoresPieChart({
    Key? key,
    required this.behaviorEntries,
    required this.traitType,
    required this.title,
  }) : super(key: key);

  @override
  State<TraitScoresPieChart> createState() => _TraitScoresPieChartState();
}

class _TraitScoresPieChartState extends State<TraitScoresPieChart> {
  int touchedIndex = -1;
  late List<MapEntry<String, double>> aggregatedScores;
  // TODO make this a class
  final Map<String, Color> traitColors = {
    // Positive traits
    'compassionate': Colors.deepPurple.shade800,
    'honest': Colors.deepPurple.shade600,
    'courageous': Colors.deepPurple.shade300,
    'ambitious': Colors.deepPurple.shade400,
    'generous': Colors.deepPurple,
    'patient': Colors.deepPurple.shade800,
    'humble': Colors.deepPurple.shade600,
    'loyal': Colors.deepPurple.shade300,
    'optimistic': Colors.deepPurple.shade400,
    'responsible': Colors.deepPurple,

    // Negative traits
    'callous': Colors.deepOrange,
    'deceitful': Colors.deepOrange.shade400,
    'cowardly': Colors.deepOrange.shade300,
    'lazy': Colors.deepOrange.shade600,
    'greedy': Colors.deepOrange.shade800,
    'impatient': Colors.deepOrange,
    'arrogant': Colors.deepOrange.shade400,
    'disloyal': Colors.deepOrange.shade300,
    'pessimistic': Colors.deepOrange.shade600,
    'irresponsible': Colors.deepOrange.shade800,
  };

  @override
  void initState() {
    super.initState();
    aggregatedScores = _aggregateScores();
  }

  List<MapEntry<String, double>> _aggregateScores() {
    Map<String, double> scores = {};

    for (var entry in widget.behaviorEntries) {
      Map<String, dynamic>? traitScores =
          entry['traitScores'] as Map<String, dynamic>?;
      if (traitScores == null || traitScores.isEmpty) continue;

      traitScores.forEach((trait, score) {
        if (!trait.endsWith('_reason')) {
          // Exclude reason traits
          double numericScore = _parseScore(score);
          if (_shouldIncludeTrait(trait, numericScore)) {
            String traitName = _getTraitName(trait, numericScore);
            scores[traitName] = (scores[traitName] ?? 0) + numericScore.abs();
          }
        }
      });
    }

    return scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  String _getTraitName(String trait, double score) {
    List<String> parts = trait.split('_');
    return score >= 0 ? parts[0] : parts[1];
  }

  bool _shouldIncludeTrait(String trait, double score) {
    switch (widget.traitType) {
      case TraitType.all:
        return score != 0;
      case TraitType.positive:
        return score > 0;
      case TraitType.negative:
        return score < 0;
    }
  }

  double _parseScore(dynamic score) {
    if (score is num) {
      return score.toDouble();
    } else if (score is String) {
      return double.tryParse(score) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.33,
      child: Column(
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.labelSmall),
          Expanded(
            child: PieChart(
              swapAnimationDuration: Duration(milliseconds: 150),
              swapAnimationCurve: Curves.bounceIn,
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 5,
                sections: showingSections(),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    if (aggregatedScores.isEmpty) {
      // Return a single grey section for empty data
      return [
        PieChartSectionData(
          color: Colors.grey.shade200,
          value: 100,
          title: '',
          radius: 45,
          titleStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
        )
      ];
    }
    return List.generate(aggregatedScores.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 8.0;
      final radius = isTouched ? 50.0 : 45.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 0)];

      final entry = aggregatedScores[i];
      final percent = (entry.value /
              aggregatedScores.map((e) => e.value).reduce((a, b) => a + b) *
              100)
          .toStringAsFixed(1);

      return PieChartSectionData(
        showTitle: true,
        color: _getColor(entry.key),
        value: entry.value,
        title: '${entry.key}'.capitalize(),
        radius: radius,
        badgePositionPercentageOffset: .90,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }

  Color _getColor(String trait) {
    return traitColors[trait.toLowerCase()] ??
        Colors.grey; // Default to grey if trait not found
  }

  String _formatTraitName(String trait) {
    return trait.capitalize();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

// Indicator class remains the same as in the previous example
class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 26,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
