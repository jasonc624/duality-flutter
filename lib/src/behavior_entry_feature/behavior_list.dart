import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
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
          return Text('An error occurred.');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('no data in snapshot');
          return const Center(child: Text('Whats going on in your day?'));
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
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            behavior.title ?? 'No title',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTime(behavior.created),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    titleTextStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    subtitleTextStyle: const TextStyle(fontSize: 14),
                    subtitle: Text(
                      behavior.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
