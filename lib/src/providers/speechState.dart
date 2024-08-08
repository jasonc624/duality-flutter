import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum TtsState { playing, stopped, paused, continued }

class TextToSpeechModel {
  final String selectedLanguage;
  final List<String> languageList;
  final TtsState ttsState;
  final String text;
  final double volume;
  final double pitch;
  final double rate;

  TextToSpeechModel({
    this.selectedLanguage = 'en-US',
    this.languageList = const ['en-US', 'es-ES', 'fr-FR', 'de-DE'],
    this.ttsState = TtsState.stopped,
    this.text = '',
    this.volume = 0.5,
    this.pitch = 1.0,
    this.rate = 0.5,
  });

  TextToSpeechModel copyWith({
    String? selectedLanguage,
    List<String>? languageList,
    TtsState? ttsState,
    String? text,
    double? volume,
    double? pitch,
    double? rate,
  }) {
    return TextToSpeechModel(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      languageList: languageList ?? this.languageList,
      ttsState: ttsState ?? this.ttsState,
      text: text ?? this.text,
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      rate: rate ?? this.rate,
    );
  }
}

class TextToSpeechNotifier extends StateNotifier<TextToSpeechModel> {
  TextToSpeechNotifier() : super(TextToSpeechModel()) {
    _initTts();
  }

  final FlutterTts flutterTts = FlutterTts();

  Future<void> _initTts() async {
    await flutterTts.setLanguage(state.selectedLanguage);
    await flutterTts.setVolume(state.volume);
    await flutterTts.setSpeechRate(state.rate);
    await flutterTts.setPitch(state.pitch);

    flutterTts.setStartHandler(() {
      state = state.copyWith(ttsState: TtsState.playing);
    });

    flutterTts.setCompletionHandler(() {
      state = state.copyWith(ttsState: TtsState.stopped);
    });

    flutterTts.setErrorHandler((msg) {
      state = state.copyWith(ttsState: TtsState.stopped);
    });
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      state = state.copyWith(text: text);
      await flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await flutterTts.stop();
    state = state.copyWith(ttsState: TtsState.stopped);
  }

  Future<void> setLanguage(String language) async {
    await flutterTts.setLanguage(language);
    state = state.copyWith(selectedLanguage: language);
  }

  Future<void> setVolume(double volume) async {
    await flutterTts.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  Future<void> setPitch(double pitch) async {
    await flutterTts.setPitch(pitch);
    state = state.copyWith(pitch: pitch);
  }

  Future<void> setRate(double rate) async {
    await flutterTts.setSpeechRate(rate);
    state = state.copyWith(rate: rate);
  }
}

class SpeechToTextModel {
  final bool isListening;
  final String recognizedText;

  SpeechToTextModel({
    this.isListening = false,
    this.recognizedText = '',
  });

  SpeechToTextModel copyWith({
    bool? isListening,
    String? recognizedText,
  }) {
    return SpeechToTextModel(
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText,
    );
  }
}

class SpeechToTextNotifier extends StateNotifier<SpeechToTextModel> {
  SpeechToTextNotifier() : super(SpeechToTextModel());

  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> initialize() async {
    bool available = await _speech.initialize();
    if (available) {
      // Speech recognition is available
    } else {
      // Speech recognition is not available
    }
  }

  Future<void> startListening() async {
    if (!state.isListening) {
      bool available = await _speech.initialize();
      if (available) {
        state = state.copyWith(isListening: true);
        _speech.listen(
          onResult: (result) {
            state = state.copyWith(recognizedText: result.recognizedWords);
          },
        );
      }
    }
  }

  Future<void> stopListening() async {
    if (state.isListening) {
      await _speech.stop();
      state = state.copyWith(isListening: false);
    }
  }
}

// Providers
final textToSpeechProvider =
    StateNotifierProvider<TextToSpeechNotifier, TextToSpeechModel>((ref) {
  return TextToSpeechNotifier();
});

final speechToTextProvider =
    StateNotifierProvider<SpeechToTextNotifier, SpeechToTextModel>((ref) {
  return SpeechToTextNotifier();
});
