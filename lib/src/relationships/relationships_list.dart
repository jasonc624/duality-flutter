import 'package:duality/src/login_page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'relationship_model.dart';

class RelationshipsPage extends StatelessWidget {
  static const routeName = '/relationships';
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      Navigator.restorablePushNamed(context, LoginScreen.routeName);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Relationships'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('relationships')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final relationships = snapshot.data?.docs
                  .map((doc) => Relationship.fromFirestore(doc))
                  .toList() ??
              [];

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
        onPressed: () => _addRelationship(context, userId.toString()),
        child: Icon(Icons.add),
        tooltip: 'Add new relationship',
      ),
    );
  }

  void _onRelationshipTap(BuildContext context, Relationship relationship) {
    // Navigate to relationship detail/edit page
    print('Tapped on ${relationship.name}');
    // You can implement navigation to a detail page here
  }

  void _addRelationship(BuildContext context, String userId) async {
    // This is a simple dialog to add a new relationship
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
                  id: '', // Firestore will generate this
                  name: nameController.text,
                  type: typeController.text.isNotEmpty
                      ? typeController.text
                      : null,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('relationships')
                    .add(newRelationship.toFirestore());

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
