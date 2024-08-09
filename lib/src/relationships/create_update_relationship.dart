import 'package:flutter/material.dart';
import 'relationship_model.dart';
import 'relationships_list.dart';
import 'repository_relationships.dart';

class CreateUpdateRelationship extends StatefulWidget {
  const CreateUpdateRelationship({Key? key, this.relationship})
      : super(key: key);
  final Relationship? relationship;
  static const routeName = '/create_update_relationship';

  @override
  _CreateUpdateRelationshipState createState() =>
      _CreateUpdateRelationshipState();
}

class _CreateUpdateRelationshipState extends State<CreateUpdateRelationship> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _tags = [];
  final List<String> _profiles = [];
  final _tagController = TextEditingController();
  final _profileController = TextEditingController();
  final RelationshipRepository _repository = RelationshipRepository();

  String _type = 'Friendship'; // Default type
  final List<String> _typeOptions = [
    'Family',
    'Romantic',
    'Friendship',
    'Professional',
    'Community',
    'Other'
  ];

  bool get _isCreating => widget.relationship == null;

  @override
  void initState() {
    super.initState();
    if (!_isCreating) {
      _nameController.text = widget.relationship!.name;
      _type = _typeOptions.contains(widget.relationship!.type)
          ? widget.relationship!.type!
          : 'Friendship';
      _tags.addAll(widget.relationship!.tags);
      _profiles.addAll(widget.relationship!.profiles);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addProfile() {
    if (_profileController.text.isNotEmpty) {
      setState(() {
        _profiles.add(_profileController.text);
        _profileController.clear();
      });
    }
  }

  void _removeProfile(String profile) {
    setState(() {
      _profiles.remove(profile);
    });
  }

  void _deleteRelationship(BuildContext context) async {
    try {
      await _repository.deleteRelationship(widget!.relationship!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: const Text('Deleted Relationship')),
      );
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => RelationshipsPage(),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting relationship: $e')),
      );
    }
  }

  Future<void> _saveRelationship() async {
    if (_formKey.currentState!.validate()) {
      try {
        final relationshipData = {
          'name': _nameController.text,
          'type': _type,
          'tags': _tags,
          'profiles': _profiles,
        };

        if (_isCreating) {
          await _repository.createRelationship(relationshipData);
        } else {
          await _repository.updateRelationship(
            widget.relationship!.id,
            relationshipData,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving relationship: $e')),
        );
      }
    }
    // Navigator.of(context).pop(true);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => RelationshipsPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isCreating ? 'Create Relationship' : 'Update Relationship'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Name', border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                  labelText: 'Relationship Type', border: OutlineInputBorder()),
              items: _typeOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _type = newValue!;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
                "Any names of individuals mentioned in your diary entries will be automatically linked to this relationship. If a relationship for a mentioned person doesn't exist, it will be created. For existing relationships, the diary entry's sentiment will be associated with that relationship.",
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Identifying Names',
                        hintText: '"John" "John Doe" "John Doe Jr."'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8.0,
              children: _tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextFormField(
            //         controller: _profileController,
            //         decoration: const InputDecoration(
            //             labelText: 'Add Profile', border: OutlineInputBorder()),
            //       ),
            //     ),
            //     IconButton(
            //       icon: const Icon(Icons.add),
            //       onPressed: _addProfile,
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 16),
            // Wrap(
            //   spacing: 8.0,
            //   children: _profiles
            //       .map((profile) => Chip(
            //             label: Text(profile),
            //             onDeleted: () => _removeProfile(profile),
            //           ))
            //       .toList(),
            // ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveRelationship,
              child: Text(_isCreating ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          child:
              Text('Delete', style: TextStyle(fontSize: 18, color: Colors.red)),
          onPressed: () {
            _deleteRelationship(context);
          },
        ),
      ),
    );
  }
}
