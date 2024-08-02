import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Firebase
import 'firebase_options.dart';
import 'src/app.dart';
// Settings
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());
  // Initialize the Flutter framework before any asynchronous work starts.
  WidgetsFlutterBinding.ensureInitialized();
  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp(settingsController: settingsController)));
}
