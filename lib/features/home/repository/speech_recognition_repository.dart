import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myrik_intern_task/features/home/home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

final speechRecognitionRepositoryProvider = Provider((ref) {
  return SpeechRecognitionRepository(
    ref,
  );
});

class SpeechRecognitionRepository {
  SpeechRecognitionRepository(this._ref) {
    listenForPermission();
    _initSpeech();
    _loadRecentSearches();
  }
  final ProviderRef<Object?> _ref;
  final SpeechToText _speechToText = SpeechToText();

  String _lastWords = '';
  final int maxRecentSearches = 5;
  List<String> recentSearches = [];

  void listenForPermission() async {
    final status = await Permission.microphone.status;
    switch (status) {
      case PermissionStatus.denied:
        requestForMicrophonePermission();
        break;
      case PermissionStatus.granted:
        break;
      case PermissionStatus.limited:
        break;
      case PermissionStatus.provisional:
        break;
      case PermissionStatus.permanentlyDenied:
        break;
      case PermissionStatus.restricted:
        break;
    }
  }

  Future<void> requestForMicrophonePermission() async {
    await Permission.microphone.request();
  }

  Future<bool> _initSpeech() async {
    print("INIT SPEECH");
    await requestForMicrophonePermission();
    print("PERMISSION REQUESTED");
    listenForPermission();

    bool status = await _speechToText.initialize();
    _ref.watch(speechEnabledPod.notifier).state = status;
    return status;
  }

  void startListening(searchController) async {
    if (!_ref.watch(speechEnabledPod.notifier).state) {
      bool isAllowed = await _initSpeech();
      if (!isAllowed) return;
    }
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      localeId: "en_IN",
      cancelOnError: false,
      partialResults: false,
      listenMode: ListenMode.confirmation,
    );
    print(_lastWords);
    _ref.watch(textRecognizedPod.notifier).state = _lastWords;
    _ref.watch(searchController.notifier).state.text = _lastWords;
    // _giveFocus();
  }

  void stopListening() async {
    await _speechToText.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
  }

  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    recentSearches = prefs.getStringList('recentSearches') ?? [];
  }

  Future<void> _addSearchToRecent(String searchTerm) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    recentSearches.insert(0, searchTerm);
    // Limit the recent searches to 'maxRecentSearches'
    if (recentSearches.length > maxRecentSearches) {
      recentSearches.removeLast();
    }

    prefs.setStringList('recentSearches', recentSearches);
  }
}
