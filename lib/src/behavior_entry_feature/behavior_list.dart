import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/uiState.dart';
import 'behavior_entry_model.dart';
import 'behavior_view.dart';

import 'repository_behavior.dart';

class BehaviorListView extends ConsumerWidget {
  static const routeName = '/';

  final String userRef;

  const BehaviorListView({Key? key, required this.userRef}) : super(key: key);
  void _viewBehavior(BuildContext context, BehaviorEntry behavior) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BehaviorView(behaviorEntry: behavior),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uistate = ref.watch(uiStateProvider);
    DateTime _selectedDate = uistate['selectedDate'];
    final BehaviorRepository _repository = BehaviorRepository();

    return StreamBuilder<List<BehaviorEntry>>(
      stream: _repository.getBehaviorsByDate(_selectedDate, userRef),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Text('An error occurred.');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('waiting');
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('no data in snapshot');
          return Center(
              child: Text(
                  'No behaviors for ${_selectedDate.toString().split(' ')[0]}'));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const Divider(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final behavior = snapshot.data![index];
            return behavior.title != null && behavior.title!.isNotEmpty
                ? ListTile(
                    title: Text(
                      behavior.title ?? 'No title',
                      maxLines: 1,
                    ),
                    titleTextStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    subtitleTextStyle: const TextStyle(fontSize: 14),
                    subtitle: Text(
                      behavior.description,
                      maxLines: 2,
                    ),
                    onTap: () => _viewBehavior(context, behavior),
                  )
                : const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
