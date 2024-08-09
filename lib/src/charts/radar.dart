import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../behavior_entry_feature/behavior_entry_model.dart';

class BehaviorRadarChart extends StatelessWidget {
  final BehaviorEntry behavior;

  BehaviorRadarChart({required this.behavior});

  @override
  Widget build(BuildContext context) {
    final traitPairs = [
      ['compassionate', 'callous'],
      ['honest', 'deceitful'],
      ['ambitious', 'lazy'],
      ['generous', 'greedy'],
      ['courageous', 'cowardly'],
      ['patient', 'impatient'],
      ['humble', 'arrogant'],
      ['loyal', 'disloyal'],
      ['optimistic', 'pessimistic'],
      ['responsible', 'irresponsible']
    ];

    String getTraitLabel(String trait) {
      return trait.capitalize();
    }

    double getTraitScore(String positiveTrait, String negativeTrait) {
      String fullTrait = '${positiveTrait}_${negativeTrait}';
      return (behavior.traitScores?[fullTrait] as num?)?.toDouble() ?? 0.0;
    }

    Widget createRadarChart() {
      return Column(
        children: [
          Text('Trait Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 360,
            child: RadarChart(
              swapAnimationDuration: const Duration(milliseconds: 400),
              RadarChartData(
                titleTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 11),
                radarShape: RadarShape.circle,
                radarBorderData:
                    const BorderSide(color: Colors.black26, width: 2),
                ticksTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 8),
                tickBorderData: const BorderSide(color: Colors.black26),
                gridBorderData:
                    const BorderSide(color: Colors.deepPurple, width: 1),
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: true),
                tickCount: 5,
                dataSets: [
                  RadarDataSet(
                    fillColor: Colors.deepPurple.withOpacity(0.2),
                    borderColor: Colors.deepPurple,
                    dataEntries: traitPairs.map((pair) {
                      double score = getTraitScore(pair[0], pair[1]);
                      return RadarEntry(value: score > 0 ? score.abs() : 0);
                    }).toList(),
                  ),
                  RadarDataSet(
                    fillColor: Colors.deepOrange.withOpacity(0.2),
                    borderColor: Colors.deepOrange,
                    dataEntries: traitPairs.map((pair) {
                      double score = getTraitScore(pair[0], pair[1]);
                      return RadarEntry(value: score < 0 ? score.abs() : 0);
                    }).toList(),
                  ),
                ],
                getTitle: (index, angle) {
                  return RadarChartTitle(
                    text:
                        '${getTraitLabel(traitPairs[index][0])}\n${getTraitLabel(traitPairs[index][1])}',
                    angle: 0,
                    positionPercentageOffset: 0.1,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 20, height: 20, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text('Positive'),
              const SizedBox(width: 20),
              Container(width: 20, height: 20, color: Colors.deepOrange),
              const SizedBox(width: 8),
              Text('Negative'),
            ],
          ),
        ],
      );
    }

    return createRadarChart();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
