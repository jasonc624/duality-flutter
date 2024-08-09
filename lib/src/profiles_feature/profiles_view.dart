import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duality/src/providers/profileState.dart';

class ProfilesOverviewWidget extends ConsumerStatefulWidget {
  static const routeName = '/profiles';
  @override
  _ProfilesOverviewWidgetState createState() => _ProfilesOverviewWidgetState();
}

class _ProfilesOverviewWidgetState
    extends ConsumerState<ProfilesOverviewWidget> {
  @override
  void initState() {
    super.initState();
    // Load profiles when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profilesProvider.notifier).loadAllProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profilesState = ref.watch(profilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddProfileDialog(context);
            },
          ),
        ],
      ),
      body: profilesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profilesState.error != null
              ? Center(child: Text('Error: ${profilesState.error}'))
              : _buildProfilesList(context, profilesState),
    );
  }

  Widget _buildProfilesList(BuildContext context, ProfilesState state) {
    final profiles = state.profiles;

    if (profiles == null || profiles.isEmpty) {
      return Center(child: Text('No profiles found.'));
    }

    return ListView.separated(
      itemCount: profiles?.length ?? 0,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(profile.name[0].toUpperCase()),
          ),
          title: Text(profile.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Created: ${_formatDate(profile.created)}'),
              Text('Default: ${profile.isDefault ? 'Yes' : 'No'}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showEditProfileDialog(context, profile);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: profile.isDefault
                    ? null // This disables the button when isDefault is true
                    : () {
                        _showDeleteConfirmation(context, profile);
                      },
                color: profile.isDefault ? Colors.grey : null,
              ),
            ],
          ),
          onTap: () {
            ref.read(profilesProvider.notifier).setCurrentProfile(profile);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('${profile.name} selected as current profile')),
            );
          },
        );
      },
    );
  }

  void _showAddProfileDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Profile'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Enter profile name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(profilesProvider.notifier).createProfile(
                        Profile(
                          created: DateTime.now(),
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          isDefault: false,
                          userRef: FirebaseAuth.instance.currentUser!.uid,
                        ),
                      );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, Profile profile) {
    final nameController = TextEditingController(text: profile.name);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Enter new profile name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(profilesProvider.notifier).updateProfile(
                        profile.copyWith(name: nameController.text),
                      );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Profile profile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Profile'),
          content: Text('Are you sure you want to delete ${profile.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // ref.read(profilesProvider.notifier).deleteProfile(profile.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
