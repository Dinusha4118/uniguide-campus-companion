import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class AiVoiceService {
  static final AiVoiceService _instance = AiVoiceService._internal();
  factory AiVoiceService() => _instance;
  AiVoiceService._internal();

  FlutterTts? _flutterTts;
  AudioPlayer? _audioPlayer;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _flutterTts = FlutterTts();
      _audioPlayer = AudioPlayer();

      await _flutterTts!.setPitch(1.35); // Clear feminine pitch
      await _flutterTts!.setSpeechRate(0.46); // Natural tempo
      await _flutterTts!.setVolume(1.0);

      _flutterTts!.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts!.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts!.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint('AiVoiceService TTS Error: $msg');
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('AiVoiceService init error: $e');
    }
  }

  /// Speaks text in English or Sinhala with high quality female voice
  Future<void> speak({
    required String text,
    required bool isSinhala,
    VoidCallback? onStart,
    VoidCallback? onComplete,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await stop();

      if (onStart != null) onStart();
      _isSpeaking = true;

      if (isSinhala) {
        // Try Sinhala TTS engine or high quality Google Translate TTS stream
        final encoded = Uri.encodeComponent(text.trim());
        bool audioPlayed = false;

        try {
          final ttsUri = Uri.parse(
            'https://translate.google.com/translate_tts?ie=UTF-8&tl=si&client=tw-ob&q=$encoded',
          );

          // Google TTS blocks requests without a browser-like User-Agent
          final response = await http.get(
            ttsUri,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.0.0 Mobile Safari/537.36',
              'Accept': '*/*',
            },
          ).timeout(const Duration(seconds: 6));

          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            if (_audioPlayer != null) {
              _audioPlayer!.onPlayerComplete.listen((_) {
                _isSpeaking = false;
                if (onComplete != null) onComplete();
              });

              await _audioPlayer!.play(BytesSource(response.bodyBytes));
              audioPlayed = true;
              debugPrint('Audio stream play success: ${response.bodyBytes.length} bytes');
            }
          } else {
            debugPrint('TTS HTTP response code: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Audio stream play fallback: $e');
          audioPlayed = false;
        }

        if (!audioPlayed && _flutterTts != null) {
          // Fallback to device TTS
          final isSiSupported = await _flutterTts!.isLanguageAvailable("si-LK");
          if (isSiSupported == true) {
            await _flutterTts!.setLanguage("si-LK");
          } else {
            await _flutterTts!.setLanguage("en-US");
          }
          await _flutterTts!.setPitch(1.35);
          await _flutterTts!.setSpeechRate(0.46);

          _flutterTts!.setCompletionHandler(() {
            _isSpeaking = false;
            if (onComplete != null) onComplete();
          });

          await _flutterTts!.speak(text);
        }
      } else {
        // English voice with high female pitch
        if (_flutterTts != null) {
          await _flutterTts!.setLanguage("en-US");
          await _flutterTts!.setPitch(1.38);
          await _flutterTts!.setSpeechRate(0.48);

          _flutterTts!.setCompletionHandler(() {
            _isSpeaking = false;
            if (onComplete != null) onComplete();
          });

          await _flutterTts!.speak(text);
        }
      }
    } catch (e) {
      _isSpeaking = false;
      debugPrint('AiVoiceService speak error: $e');
      if (onComplete != null) onComplete();
    }
  }

  Future<void> stop() async {
    try {
      if (_flutterTts != null) {
        await _flutterTts!.stop();
      }
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
      }
      _isSpeaking = false;
    } catch (e) {
      debugPrint('AiVoiceService stop error: $e');
    }
  }
}
