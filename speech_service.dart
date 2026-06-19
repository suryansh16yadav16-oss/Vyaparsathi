import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;

  Future<bool> initialize() async {
    return await _speech.initialize(
      onStatus: (status) {},
      onError: (error) {},
    );
  }

  void startListening(Function(String) onResult) {
    if (!_speech.isAvailable) return;
    _isListening = true;
    _speech.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        onResult(_recognizedText);
      },
      listenMode: stt.ListenMode.dictation,
    );
  }

  void stopListening() {
    _isListening = false;
    _speech.stop();
  }

  void dispose() {
    _speech.stop();
  }
}
