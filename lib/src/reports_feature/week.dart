import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../behavior_entry_feature/behavior_entry_model.dart';
import '../behavior_entry_feature/repository_behavior.dart';
import '../charts/weekly_bar.dart';
import 'package:intl/intl.dart';

class WeekView extends StatelessWidget {
  final int weekNumber;

  WeekView({
    Key? key,
    required this.weekNumber,
  }) : super(key: key);
  final BehaviorRepository behaviorRepository = BehaviorRepository();

  final List<String> traits = [
    'compassionate_callous',
    'honest_deceitful',
    'courageous_cowardly',
    'ambitious_lazy',
    'generous_greedy',
    'patient_impatient',
    'humble_arrogant',
    'loyal_disloyal',
    'optimistic_pessimistic',
    'responsible_irresponsible',
  ];
  final userRef = FirebaseAuth.instance.currentUser!.uid;

  (DateTime, DateTime) _getWeekDates() {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final firstMondayOfYear = firstDayOfYear.add(
      Duration(days: (8 - firstDayOfYear.weekday) % 7),
    );

    final weekStart =
        firstMondayOfYear.add(Duration(days: 7 * (weekNumber - 1)));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return (weekStart, weekEnd);
  }

  Stream<Map<int, List<double>>> _getFormattedData() {
    final (startDate, endDate) = _getWeekDates();

    return behaviorRepository
        .getBehaviorsForWeek(startDate, endDate, userRef)
        .map((behaviorsByDay) {
      Map<int, List<double>> formattedData = {};
      behaviorsByDay.forEach((day, behaviors) {
        formattedData[day] = _processTraitScores(behaviors);
      });
      return formattedData;
    });
  }

  List<double> _processTraitScores(List<BehaviorEntry> behaviors) {
    Map<String, double> traitTotals = {for (var trait in traits) trait: 0};
    Map<String, int> traitCounts = {for (var trait in traits) trait: 0};

    for (var behavior in behaviors) {
      if (behavior.traitScores != null) {
        behavior.traitScores!.forEach((trait, score) {
          if (traits.contains(trait) && score is num) {
            traitTotals[trait] = (traitTotals[trait] ?? 0) + score;
            traitCounts[trait] = (traitCounts[trait] ?? 0) + 1;
          }
        });
      }
    }

    return traits.map((trait) {
      if (traitCounts[trait] == 0) return 0.0;
      return traitTotals[trait]! / traitCounts[trait]!;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final (startDate, endDate) = _getWeekDates();

    return Scaffold(
      appBar: AppBar(
        title: Text('Week $weekNumber'),
      ),
      body: Column(
        children: [
          Text(
            'Week from ${DateFormat('M/d/yy').format(startDate)} '
            'to ${DateFormat('M/d/yy').format(endDate.subtract(Duration(days: 1)))}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: StreamBuilder<Map<int, List<double>>>(
              stream: _getFormattedData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No data available',
                              style: TextStyle(fontSize: 20))));
                } else {
                  return WeeklyBarChart(
                    startDate: startDate,
                    endDate: endDate,
                    data: snapshot.data!,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
