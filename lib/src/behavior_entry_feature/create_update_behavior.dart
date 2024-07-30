import 'package:flutter/material.dart';
import 'behavior_entry_model.dart';
import 'repository_behavior.dart';

class CreateUpdateBehavior extends StatefulWidget {
  const CreateUpdateBehavior({Key? key, this.behaviorEntry}) : super(key: key);
  final BehaviorEntry? behaviorEntry;
  static const routeName = '/create_update_behavior';

  @override
  _CreateUpdateBehaviorState createState() => _CreateUpdateBehaviorState();
}

class _CreateUpdateBehaviorState extends State<CreateUpdateBehavior> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _repository = BehaviorRepository();

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
        final newBehavior = BehaviorEntry(description: description);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.behaviorEntry == null
            ? 'Create Behavior'
            : 'Update Behavior'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.behaviorEntry == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
