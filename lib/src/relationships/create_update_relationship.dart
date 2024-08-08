import 'package:flutter/material.dart';

import 'relationship_model.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create/Update Relationship'),
      ),
      body: Center(
        child: Text('Create/Update Relationship'),
      ),
    );
  }
}
