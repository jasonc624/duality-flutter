import 'package:duality/src/login_page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'relationship_model.dart';
import 'relationship_view.dart';
import 'repository_relationships.dart';

class RelationshipsPage extends StatelessWidget {
  static const routeName = '/relationships';
  final RelationshipRepository _repository = RelationshipRepository();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.restorablePushNamed(context, LoginScreen.routeName);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Relationships'),
      ),
      body: StreamBuilder<List<Relationship>>(
        stream: _repository.getAllRelationships(),
        builder: (context, snapshot) {
          print('builder snapshot:${snapshot.data}');
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          print('builder ?${snapshot.data}');

          final relationships = snapshot.data ?? [];

          return ListView.builder(
            itemCount: relationships.length,
            itemBuilder: (context, index) {
              final relationship = relationships[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    relationship.name.isNotEmpty
                        ? relationship.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(relationship.name),
                subtitle: Text(relationship.type ?? 'No type specified'),
                onTap: () => _onRelationshipTap(context, relationship),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRelationship(context),
        child: Icon(Icons.add),
        tooltip: 'Add new relationship',
      ),
    );
  }

  void _onRelationshipTap(BuildContext context, Relationship relationship) {
    print('Tapped on ${relationship.name}');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RelationshipView(relationship: relationship),
      ),
    );
  }

  void _addRelationship(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController typeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Relationship'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final newRelationship = Relationship(
                  id: '', // Repository will handle this
                  name: nameController.text,
                  type: typeController.text.isNotEmpty
                      ? typeController.text
                      : null,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await _repository.createRelationship(newRelationship);
                Navigator.of(context).pop();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
