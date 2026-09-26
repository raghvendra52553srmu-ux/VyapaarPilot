// Stub implementation for non-web environments (tests, VM, desktop)

typedef SpeechRecognitionCallback = void Function(String text);

class WebAudioHelper {
  static void playAudioUrl(String url) {}
  static void speakText(String text, String language) {}
  static bool get isSpeechRecognitionSupported => false;
  static void startListening({
    required String language,
    required SpeechRecognitionCallback onResult,
    required VoidCallback onError,
    required VoidCallback onEnd,
  }) {}
  static void stopListening() {}
}

typedef VoidCallback = void Function();
