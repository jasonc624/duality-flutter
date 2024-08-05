import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profileState.dart';

class ProfileListWidget extends ConsumerStatefulWidget {
  const ProfileListWidget({Key? key}) : super(key: key);

  @override
  _ProfileListWidgetState createState() => _ProfileListWidgetState();
}

class _ProfileListWidgetState extends ConsumerState<ProfileListWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profilesProvider.notifier).loadAllProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profilesState = ref.watch(profilesProvider);

    return profilesState.isLoading
        ? const Center(child: CircularProgressIndicator())
        : profilesState.error != null
            ? Center(child: Text('Error: ${profilesState.error}'))
            : _buildProfileContent(profilesState);
  }

  Widget _buildProfileContent(ProfilesState state) {
    final profiles = state.profiles;
    final currentProfile = state.profile;

    if (profiles == null || profiles.isEmpty) {
      return Center(child: Text('No profiles found.'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            dropdownColor: Colors.black,
            alignment: AlignmentDirectional.center,
            style: const TextStyle(color: Colors.white),
            isExpanded: false,
            isDense: false,
            value: currentProfile?.id,
            hint: const Text('Select a profile'),
            items: profiles.map((Profile profile) {
              return DropdownMenuItem<String>(
                alignment: AlignmentDirectional.center,
                value: profile.id,
                child: Text(profile.name,
                    style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (String? newProfileId) {
              if (newProfileId != null) {
                final newProfile =
                    profiles.firstWhere((p) => p.id == newProfileId);
                ref
                    .read(profilesProvider.notifier)
                    .setCurrentProfile(newProfile);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileList(List<Profile> profiles) {
    return ListView.builder(
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return ListTile(
          title: Text(profile.name),
        );
      },
    );
  }
}
