import 'package:flutter/material.dart';
import '../services/speech_service.dart';

class VoiceOrderScreen extends StatefulWidget {
  const VoiceOrderScreen({super.key});

  @override
  State<VoiceOrderScreen> createState() => _VoiceOrderScreenState();
}

class _VoiceOrderScreenState extends State<VoiceOrderScreen> {
  final SpeechService _speechService = SpeechService();
  String _recognizedText = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speechService.initialize();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      _speechService.startListening((text) {
        setState(() {
          _recognizedText = text;
        });
      });
      setState(() => _isListening = true);
    }
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Order')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundColor: _isListening ? Colors.green : Colors.grey,
              child: IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 48),
                color: Colors.white,
                onPressed: _toggleListening,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _isListening ? 'Listening...' : 'Tap microphone to start',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _recognizedText.isEmpty
                    ? 'Recognized text will appear here'
                    : _recognizedText,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
