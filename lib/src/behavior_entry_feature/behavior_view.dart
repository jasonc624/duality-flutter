import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../charts/radar.dart';
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

class _BehaviorViewState extends State<BehaviorView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _repository = BehaviorRepository();
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    if (widget.behaviorEntry != null) {
      _descriptionController.text = widget.behaviorEntry!.description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text;

      if (widget.behaviorEntry == null) {
        // Create new behavior
        final newBehavior =
            BehaviorEntry(description: description, userRef: currentUserUid);
        String newId = await _repository.addBehavior(newBehavior);

        // Fetch the complete document
        BehaviorEntry createdBehavior = await _repository.getBehavior(newId);

        // Now you can see the complete response
        print('Created Behavior: ${createdBehavior.id}');
        print('Title: ${createdBehavior.title}');
        print('Description: ${createdBehavior.description}');
        print('Trait Scores: ${createdBehavior.traitScores}');
        print('Created: ${createdBehavior.created}');
        print('Updated: ${createdBehavior.updated}');
      } else {
        // Update existing behavior
        final updatedBehavior =
            widget.behaviorEntry!.copyWith(description: description);
        await _repository.updateBehavior(updatedBehavior);
      }

      Navigator.of(context).pop();
    }
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
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.behaviorEntry?.title ?? 'Untitled ',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(widget.behaviorEntry?.description ?? "",
                  style: const TextStyle(
                      fontSize: 16, fontStyle: FontStyle.italic)),
              const SizedBox(height: 30),
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    onPressed: () =>
                        _editBehavior(context, widget.behaviorEntry!),
                    child: Text('Edit'))
              ]),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 30),
              if (widget.behaviorEntry != null &&
                  widget.behaviorEntry!.traitScores != null)
                BehaviorRadarChart(behavior: widget.behaviorEntry!),
            ],
          ),
        )));
  }
}
