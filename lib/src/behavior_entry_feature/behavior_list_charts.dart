import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../charts/pie.dart';
import '../providers/uiState.dart';
import 'behavior_entry_model.dart';
import 'repository_behavior.dart';

class BehaviorAnalysisPieCharts extends ConsumerWidget {
  final String userRef;

  const BehaviorAnalysisPieCharts({Key? key, required this.userRef})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uistate = ref.watch(uiStateProvider);
    DateTime _selectedDate = uistate['selectedDate'];
    final BehaviorRepository _repository = BehaviorRepository();

    return StreamBuilder<List<BehaviorEntry>>(
      stream: _repository.getBehaviorsByDate(_selectedDate, userRef),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('An error occurred loading behavior data.');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // No charts if no data
        }

        List<Map<String, dynamic>> behaviorEntries =
            snapshot.data!.map((behavior) {
          var traitScores = behavior.traitScores;
          if (traitScores != null) {
            traitScores = traitScores.map((key, value) {
              if (value is int || value is double) {
                return MapEntry(key, value.toDouble());
              }
              return MapEntry(key, 0.0); // Default value if not a number
            });
          }
          return {
            'id': behavior.id,
            'date': behavior.created.toString(),
            'traitScores': traitScores,
          };
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: TraitScoresPieChart(
                  behaviorEntries: behaviorEntries,
                  traitType: TraitType.positive,
                  title: 'Positive',
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: TraitScoresPieChart(
                  behaviorEntries: behaviorEntries,
                  traitType: TraitType.negative,
                  title: 'Negative',
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: TraitScoresPieChart(
                  behaviorEntries: behaviorEntries,
                  traitType: TraitType.all,
                  title: 'All Traits',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
