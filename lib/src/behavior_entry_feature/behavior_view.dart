import 'package:flutter/material.dart';
import '../charts/radar.dart';
import '../traits/trait_score_view.dart';
import 'behavior_entry_model.dart';
import 'create_update_behavior.dart';
import 'repository_behavior.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BehaviorView extends StatefulWidget {
  const BehaviorView({Key? key, this.behaviorEntry}) : super(key: key);
  final BehaviorEntry? behaviorEntry;
  static const routeName = '/create_update_behavior';

  @override
  _BehaviorViewState createState() => _BehaviorViewState();
}

class _BehaviorViewState extends State<BehaviorView>
    with SingleTickerProviderStateMixin {
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _editBehavior(BuildContext context, BehaviorEntry behavior) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateUpdateBehavior(behaviorEntry: behavior),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Behavior'),
          actions: [
            if (widget.behaviorEntry != null)
              TextButton(
                  onPressed: () =>
                      _editBehavior(context, widget.behaviorEntry!),
                  child: const Text('Edit'))
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Explanation'),
              Tab(text: 'Visualize'),
              Tab(text: 'Disorders'),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 16.0),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTraitScoresTab(),
                  _buildRadarChartTab(),
                  _buildDisordersTab(),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildDisordersTab() {
    if (widget.behaviorEntry == null ||
        widget.behaviorEntry!.disorders == null) {
      return const Center(child: Text('No connection to a disorder found.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        children: widget.behaviorEntry!.disorders!
            .map((disorder) => _buildDisorderEntry(disorder))
            .toList(),
      ),
    );
  }

  Widget _buildDisorderEntry(Disorder disorder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          disorder.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(disorder.reason),
        const SizedBox(height: 8),
        Text('Score: ${disorder.score}'),
        const Divider(height: 30, thickness: 1),
      ],
    );
  }

  Widget _buildTraitScoresTab() {
    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: Column(children: [
          Text(widget.behaviorEntry?.title ?? 'Untitled ',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(widget.behaviorEntry?.description ?? "",
              style:
                  const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 30),
          if (widget.behaviorEntry != null &&
              widget.behaviorEntry!.suggestion != null)
            _buildSuggestion(widget.behaviorEntry!.suggestion!),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 30),
          widget.behaviorEntry != null &&
                  widget.behaviorEntry!.traitScores != null
              ? _buildTraitScores(widget.behaviorEntry!.traitScores!)
              : const Text('No trait scores available.'),
        ]));
  }

  Widget _buildRadarChartTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: widget.behaviorEntry != null &&
              widget.behaviorEntry!.traitScores != null
          ? BehaviorRadarChart(behavior: widget.behaviorEntry!)
          : const Text('No chart data available.'),
    );
  }

  Widget _buildSuggestion(String suggestion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggestion',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(suggestion)
      ],
    );
  }

  Widget _buildTraitScores(Map<String, dynamic> traitScores) {
    List<Widget> traitScoreWidgets = [];

    traitScores.entries
        .where((entry) => !entry.key.endsWith('_reason'))
        .forEach((entry) {
      String trait = entry.key;
      dynamic score = entry.value;

      // Convert score to int if it's a number, otherwise use 0
      int numericScore = (score is num) ? score.toInt() : 0;

      // Skip this trait if the score is 0
      if (numericScore == 0) return;

      String reason =
          traitScores['${trait}_reason']?.toString() ?? 'No reason provided';

      traitScoreWidgets.add(
        TraitScoreView(
          trait: trait,
          score: numericScore,
          reason: reason,
        ),
      );
    });

    // If no non-zero scores, return an empty container
    if (traitScoreWidgets.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explanation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...traitScoreWidgets,
      ],
    );
  }
}
