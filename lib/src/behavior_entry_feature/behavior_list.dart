import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'behavior_entry_model.dart';
import 'create_update_behavior.dart';
import 'repository_behavior.dart';

class BehaviorListView extends StatelessWidget {
  static const routeName = '/';

  final DateTime selectedDate;

  const BehaviorListView({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BehaviorRepository _repository = BehaviorRepository();

    return StreamBuilder<List<BehaviorEntry>>(
      stream: _repository.getBehaviorsByDate(selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text(
                  'No behaviors for ${selectedDate.toString().split(' ')[0]}'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final behavior = snapshot.data![index];
            return behavior.title != null && behavior.title!.isNotEmpty
                ? ListTile(
                    title: Text(behavior.title ?? 'No title'),
                    subtitle: Text(behavior.description),
                    onTap: () => _editBehavior(context, behavior),
                  )
                : const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  void _editBehavior(BuildContext context, BehaviorEntry behavior) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateUpdateBehavior(behaviorEntry: behavior),
      ),
    );
  }
}
