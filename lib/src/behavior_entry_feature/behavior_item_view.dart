import 'package:flutter/material.dart';

class BehaviorItemView extends StatelessWidget {
  const BehaviorItemView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavior Entry'),
      ),
      body: const Center(
        child: Text('More Information Here'),
      ),
    );
  }
}
