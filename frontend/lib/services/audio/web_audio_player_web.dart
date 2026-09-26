// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

typedef SpeechRecognitionCallback = void Function(String text);
typedef VoidCallback = void Function();

class WebAudioHelper {
  static html.SpeechRecognition? _recognition;

  /// Plays synthesized audio from a URL (e.g. backend /api/ai/voice/audio/{id})
  static void playAudioUrl(String url) {
    try {
      final audio = html.AudioElement(url);
      audio.autoplay = true;
      audio.play().catchError((e) {
        // Autoplay may be blocked by browser user-gesture policy until tapped
      });
    } catch (_) {}
  }

  /// Synthesizes speech locally in browser using Web Speech API (TTS)
  static void speakText(String text, String language) {
    try {
      if (html.window.speechSynthesis != null) {
        html.window.speechSynthesis!.cancel();
        final utterance = html.SpeechSynthesisUtterance(text);
        final lang = language.toLowerCase();
        if (lang.contains('hi')) {
          utterance.lang = 'hi-IN';
        } else {
          utterance.lang = 'en-IN';
        }
        utterance.rate = 1.0;
        utterance.pitch = 1.0;
        html.window.speechSynthesis!.speak(utterance);
      }
    } catch (_) {}
  }

  /// Whether Web Speech Recognition (STT) is supported in current browser
  static bool get isSpeechRecognitionSupported {
    try {
      return html.SpeechRecognition.supported;
    } catch (_) {
      return false;
    }
  }

  /// Starts browser microphone speech recognition (STT)
  static void startListening({
    required String language,
    required SpeechRecognitionCallback onResult,
    required VoidCallback onError,
    required VoidCallback onEnd,
  }) {
    try {
      if (!html.SpeechRecognition.supported) {
        onError();
        return;
      }

      final recognition = html.SpeechRecognition();
      _recognition = recognition;
      final langCode = language.toLowerCase().contains('hi') ? 'hi-IN' : 'en-IN';
      recognition.lang = langCode;
      recognition.continuous = false;
      recognition.interimResults = false;

      recognition.onResult.listen((event) {
        try {
          final results = event.results;
          if (results != null && results.isNotEmpty) {
            final first = results.first;
            final transcript = first.item(0).transcript;
            if (transcript != null && transcript.trim().isNotEmpty) {

              onResult(transcript);
            }
          }
        } catch (_) {
          onError();
        }
      });

      recognition.onError.listen((_) => onError());
      recognition.onEnd.listen((_) => onEnd());

      recognition.start();
    } catch (e) {
      onError();
    }
  }

  /// Stops current speech recognition session
  static void stopListening() {
    try {
      _recognition?.stop();
      _recognition = null;
    } catch (_) {}
  }
}
