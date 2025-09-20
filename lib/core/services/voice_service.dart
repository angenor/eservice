import 'dart:async';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class VoiceService {
  Future<bool> initialize();
  Future<bool> startListening({Function(String)? onResult});
  Future<void> stopListening();
  Future<String> transcribeAudio(String audioPath);
  Future<void> speakText(String text, {String language = 'fr-FR'});
  Stream<String> getTranscriptionStream();
  Future<void> setLanguage(String languageCode);
  Future<bool> isListening();
  Future<void> dispose();
}

@LazySingleton(as: VoiceService)
class VoiceServiceImpl implements VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final StreamController<String> _transcriptionController = StreamController<String>.broadcast();
  
  bool _isInitialized = false;
  String _currentLanguage = 'fr-FR';
  
  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    // Request microphone permission
    final microphoneStatus = await Permission.microphone.request();
    if (!microphoneStatus.isGranted) {
      throw Exception('Microphone permission not granted');
    }
    
    // Initialize speech to text
    _isInitialized = await _speechToText.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
    
    if (!_isInitialized) {
      throw Exception('Failed to initialize speech recognition');
    }
    
    // Initialize TTS
    await _configureTTS();
    
    return _isInitialized;
  }
  
  Future<void> _configureTTS() async {
    await _flutterTts.setLanguage(_currentLanguage);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    if (Platform.isIOS) {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
      );
    }
  }
  
  @override
  Future<bool> startListening({Function(String)? onResult}) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (await _speechToText.hasPermission) {
      await _speechToText.listen(
        onResult: (result) {
          final text = result.recognizedWords;
          _transcriptionController.add(text);
          if (onResult != null) {
            onResult(text);
          }
        },
        localeId: _currentLanguage,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onDevice: false,
      );
      return true;
    }
    return false;
  }
  
  @override
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
  
  @override
  Future<String> transcribeAudio(String audioPath) async {
    // This would require additional implementation with a speech-to-text API
    // For now, return a placeholder
    throw UnimplementedError('Audio file transcription not yet implemented');
  }
  
  @override
  Future<void> speakText(String text, {String language = 'fr-FR'}) async {
    if (language != _currentLanguage) {
      await _flutterTts.setLanguage(language);
    }
    
    await _flutterTts.speak(text);
    
    if (language != _currentLanguage) {
      await _flutterTts.setLanguage(_currentLanguage);
    }
  }
  
  @override
  Stream<String> getTranscriptionStream() {
    return _transcriptionController.stream;
  }
  
  @override
  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _flutterTts.setLanguage(languageCode);
  }
  
  @override
  Future<bool> isListening() async {
    return _speechToText.isListening;
  }
  
  @override
  Future<void> dispose() async {
    await _speechToText.cancel();
    await _flutterTts.stop();
    await _transcriptionController.close();
  }
}