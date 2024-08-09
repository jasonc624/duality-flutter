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

  @override
  void initState() {
    super.initState();
    aggregatedScores = _aggregateScores();
  }

  List<MapEntry<String, double>> _aggregateScores() {
    Map<String, double> scores = {};

    for (var entry in widget.behaviorEntries) {
      Map<String, dynamic> traitScores = entry['traitScores'];
      traitScores.forEach((trait, score) {
        double numericScore = _parseScore(score);
        if (_shouldIncludeTrait(trait, numericScore)) {
          scores[trait] = (scores[trait] ?? 0) + numericScore.abs();
        }
      });
    }

    return scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
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
                centerSpaceRadius: 20,
                sections: showingSections(),
              ),
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: aggregatedScores
                .map((entry) => Indicator(
                    color: _getColor(entry.key),
                    text: _formatTraitName(entry.key),
                    isSquare: true))
                .toList(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(aggregatedScores.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 45.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final entry = aggregatedScores[i];
      final percent = (entry.value /
              aggregatedScores.map((e) => e.value).reduce((a, b) => a + b) *
              100)
          .toStringAsFixed(1);

      return PieChartSectionData(
        color: _getColor(entry.key),
        value: entry.value,
        title: '$percent%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }

  Color _getColor(String trait) {
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.cyan
    ];
    return colors[
        aggregatedScores.indexWhere((element) => element.key == trait) %
            colors.length];
  }

  String _formatTraitName(String trait) {
    return trait.split('_')[0].capitalize();
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
    this.size = 12,
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
