import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';

import '../behavior_entry_feature/behavior_entry_model.dart';

class BehaviorRadarChart extends StatelessWidget {
  final BehaviorEntry behavior;

  BehaviorRadarChart({required this.behavior});

  @override
  Widget build(BuildContext context) {
    // Define all trait pairs
    final traitPairs = [
      ['compassionate', 'callous'],
      ['honest', 'deceitful'],
      ['courageous', 'cowardly'],
      ['ambitious', 'lazy'],
      ['generous', 'greedy'],
    ];

    // Function to get a human-readable label from the trait key
    String getTraitLabel(String trait) {
      return trait.capitalize();
    }

    // Function to get the score for a trait pair
    double getTraitScore(String positiveTrait, String negativeTrait) {
      String fullTrait = '${positiveTrait}_${negativeTrait}';
      return (behavior.traitScores?[fullTrait] as num?)?.toDouble() ??
          2.0; // Default to neutral if not present
    }

    // Function to create a radar chart
    Widget createRadarChart(bool isPositive) {
      String title = isPositive ? 'Positive Traits' : 'Negative Traits';
      Color color = isPositive ? Colors.blue : Colors.red;

      return Column(
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 250, // Adjust this value as needed
            child: RadarChart(
              RadarChartData(
                titleTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 11),
                radarShape: RadarShape.polygon,
                radarBorderData:
                    const BorderSide(color: Colors.black, width: 2),
                ticksTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 8),
                tickBorderData: const BorderSide(color: Colors.grey),
                gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                tickCount: 5,
                dataSets: [
                  RadarDataSet(
                    fillColor: color.withOpacity(0.2),
                    borderColor: color,
                    dataEntries: traitPairs.map((pair) {
                      double score = getTraitScore(pair[0], pair[1]);
                      return RadarEntry(
                          value: isPositive
                              ? (score > 2 ? score - 2 : 0)
                              : // For positive traits, show values above neutral
                              (score < 2
                                  ? 2 - score
                                  : 0) // For negative traits, show values below neutral
                          );
                    }).toList(),
                  ),
                ],
                getTitle: (index, angle) {
                  return RadarChartTitle(
                    text: getTraitLabel(isPositive
                        ? traitPairs[index][0]
                        : traitPairs[index][1]),
                    angle: 0,
                    positionPercentageOffset: 0.1,
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        createRadarChart(true), // Positive traits
        SizedBox(height: 30), // Add some space between the charts
        createRadarChart(false), // Negative traits
      ],
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
