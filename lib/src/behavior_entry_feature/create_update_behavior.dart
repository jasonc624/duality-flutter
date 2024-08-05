import 'package:flutter/material.dart';
import 'behavior_entry_model.dart';
import 'repository_behavior.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CreateUpdateBehavior extends StatefulWidget {
  const CreateUpdateBehavior({Key? key, this.behaviorEntry}) : super(key: key);
  final BehaviorEntry? behaviorEntry;
  static const routeName = '/create_update_behavior';

  @override
  _CreateUpdateBehaviorState createState() => _CreateUpdateBehaviorState();
}

class _CreateUpdateBehaviorState extends State<CreateUpdateBehavior> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repository = BehaviorRepository();
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  List<String> _profiles = [];
  String? _selectedProfile;
  List<String> _mentions = [];
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    if (widget.behaviorEntry != null) {
      _descriptionController.text = widget.behaviorEntry!.description;
      _dateController.text =
          DateFormat('yyyy-MM-dd').format(widget.behaviorEntry!.created);
      _selectedProfile = widget.behaviorEntry!.profile;
      _mentions = widget.behaviorEntry!.mentions ?? [];
      _isPublic = widget.behaviorEntry!.isPublic ?? false;
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  void _loadProfiles() async {
    final profilesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('profiles')
        .get();

    setState(() {
      _profiles = profilesSnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    //TODO: Implement default created date from state
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text;
      final created = DateFormat('yyyy-MM-dd').parse(_dateController.text);
      if (widget.behaviorEntry == null) {
        // Create new behavior
        final newBehavior = BehaviorEntry(
          description: description,
          userRef: currentUserUid,
          created: created,
          isPublic: _isPublic,
        );
        await _repository.addBehavior(newBehavior);
      } else {
        print('updated ${created}');
        // Update existing behavior
        final updatedBehavior = widget.behaviorEntry!.copyWith(
          description: description,
          created: created,
          profile: _selectedProfile,
          mentions: _mentions,
          isPublic: _isPublic,
        );
        await _repository.updateBehavior(updatedBehavior);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNewEntry = widget.behaviorEntry == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewEntry ? 'New Behavior' : 'Update Behavior'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                      hintText:
                          'Enter in something you did or an interaction you had, this works best when you write it in the first person.'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                  title: const Text('Make Public'),
                  value: _isPublic,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPublic = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (!isNewEntry) ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateFormat('yyyy-MM-dd')
                            .parse(_dateController.text),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        setState(() {
                          _dateController.text = formattedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Profile'),
                    value: _selectedProfile,
                    items: _profiles.map((String profile) {
                      return DropdownMenuItem<String>(
                        value: profile,
                        child: Text(profile),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedProfile = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a profile';
                      }
                      return null;
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Mentions'),
                    onChanged: (value) {
                      setState(() {
                        _mentions = value
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                      });
                    },
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: _mentions
                        .map((mention) => Chip(
                              label: Text(mention),
                              onDeleted: () {
                                setState(() {
                                  _mentions.remove(mention);
                                });
                              },
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(isNewEntry ? 'Analyze' : 'Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
