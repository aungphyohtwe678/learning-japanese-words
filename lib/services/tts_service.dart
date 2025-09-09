import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set language to Japanese
      await _flutterTts.setLanguage('ja-JP');
      
      // Set speech rate (speed)
      await _flutterTts.setSpeechRate(0.5);
      
      // Set volume
      await _flutterTts.setVolume(0.8);
      
      // Set pitch
      await _flutterTts.setPitch(1.0);

      _isInitialized = true;
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  static Future<void> speakJapanese(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) return;

    try {
      // Stop any current speech
      await _flutterTts.stop();
      
      // Set language to Japanese for Japanese text
      await _flutterTts.setLanguage('ja-JP');
      
      // Speak the text
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking Japanese text: $e');
    }
  }

  static Future<void> speakEnglish(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) return;

    try {
      // Stop any current speech
      await _flutterTts.stop();
      
      // Set language to English for English text
      await _flutterTts.setLanguage('en-US');
      
      // Speak the text
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking English text: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  static Future<bool> isLanguageAvailable(String language) async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages.contains(language);
    } catch (e) {
      print('Error checking language availability: $e');
      return false;
    }
  }
}
