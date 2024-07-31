import 'package:duality/src/behavior_entry_feature/behavior_list.dart';
import 'package:flutter/material.dart';

import '../behavior_entry_feature/create_update_behavior.dart';
import '../settings/settings_view.dart';
import 'timeline/bg_timeline.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  static const routeName = '/home';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now();

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.restorablePushNamed(context, MyHomePage.routeName);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.restorablePushNamed(context, SettingsView.routeName);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            CustomBackgroundExample(
              onDateChanged: _onDateChanged,
              initialDate: _selectedDate,
            ),
            const SizedBox(height: 16.0),
            BehaviorListView(selectedDate: _selectedDate),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createBehavior(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _createBehavior(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateUpdateBehavior(),
      ),
    );
  }
}
