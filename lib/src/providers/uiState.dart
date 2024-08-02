import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'uiState.g.dart';

@riverpod
class UiState extends _$UiState {
  @override
  Map<String, dynamic> build() =>
      {'selectedDate': DateTime.now(), 'selectedProfile': ''};

  void setDate(DateTime selectedDate) {
    state = {
      'selectedDate': selectedDate,
      'selectedProfile': state['selectedProfile']
    };
    printState();
  }

  void setProfile(String selectedProfileId) {
    state = {
      'selectedDate': state['selectedDate'],
      'selectedProfile': selectedProfileId
    };
    printState();
  }

  DateTime getDate() => state['selectedDate'] ?? DateTime.now();
  String getCurrentProfile() => state['selectedProfile'] ?? 'default';

  void printState() {
    print('Current state: $state');
  }
}
