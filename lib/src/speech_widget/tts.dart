import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/speechState.dart';
// Import your TextToSpeechNotifier file

class SpeakTextWidget extends ConsumerWidget {
  final String textToSpeak;

  const SpeakTextWidget({Key? key, required this.textToSpeak})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(textToSpeechProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (ttsState.ttsState != TtsState.playing)
                ElevatedButton.icon(
                  onPressed: ttsState.ttsState != TtsState.playing
                      ? () => ref
                          .read(textToSpeechProvider.notifier)
                          .speak(textToSpeak)
                      : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Speak'),
                ),
              if (ttsState.ttsState == TtsState.playing)
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(textToSpeechProvider.notifier).stop(),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
