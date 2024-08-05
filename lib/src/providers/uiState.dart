import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'uiState.g.dart';

@riverpod
class UiState extends _$UiState {
  @override
  Map<String, dynamic> build() => {
        'selectedDate': DateTime.now(),
      };

  void setDate(DateTime selectedDate) {
    state = {
      'selectedDate': selectedDate,
      'selectedProfile': state['selectedProfile'],
      'profiles': state['profiles']
    };
    printState();
  }

  DateTime getDate() => state['selectedDate'] ?? DateTime.now();

  void printState() {
    print('Current state: $state');
  }
}
