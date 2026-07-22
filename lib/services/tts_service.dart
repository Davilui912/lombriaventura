// lib/services/tts_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '/secrets.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  AudioPlayer? _player;
  bool _isSpeaking = false;

  static const String _apiKey = Secrets.googleTtsApiKey;

  // ✅ VOZ NEURAL - ESPAÑOL (ES-US) - FUNCIONA
  static const String _voz = 'es-US-Neural2-A';

  Future<bool> speak(String texto) async {
    try {
      final textoLimpio = _limpiarTexto(texto);
      if (textoLimpio.isEmpty) return false;

      // ✅ Si ya está hablando, detener y esperar
      if (_isSpeaking) {
        await stop();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // ✅ Crear un nuevo AudioPlayer cada vez
      _player = AudioPlayer();
      _isSpeaking = true;

      print('🔊 Enviando texto a Google TTS: $textoLimpio');

      final response = await http.post(
        Uri.parse('https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'input': {'text': textoLimpio},
          'voice': {
            'languageCode': 'es-US',
            'name': _voz,
          },
          'audioConfig': {
            'audioEncoding': 'MP3',
            'speakingRate': 0.85,
            'pitch': 1.0,
          },
        }),
      );

      if (response.statusCode != 200) {
        print('❌ Status Code: ${response.statusCode}');
        print('❌ Error completo: ${response.body}');
        _isSpeaking = false;
        _player?.dispose();
        _player = null;
        return false;
      }

      final data = jsonDecode(response.body);
      final audioBytes = base64Decode(data['audioContent']);

      // ✅ Reproducir el audio
      await _player!.play(BytesSource(audioBytes));

      // ✅ Escuchar cuando termine
      _player!.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          _isSpeaking = false;
          print('🔊 TTS finalizado: $state');
          _player?.dispose();
          _player = null;
        }
      });

      return true;
    } catch (e) {
      print('❌ Error en TTS: $e');
      _isSpeaking = false;
      _player?.dispose();
      _player = null;
      return false;
    }
  }

  Future<void> stop() async {
    try {
      if (_player != null) {
        await _player!.stop();
        await _player!.dispose();
        _player = null;
      }
    } catch (e) {
      print('❌ Error al detener: $e');
    }
    _isSpeaking = false;
  }

  bool get isSpeaking => _isSpeaking;

  String _limpiarTexto(String texto) {
    final regex = RegExp(
      r'[^A-Za-zÁÉÍÓÚáéíóúÑñÜü\s.,;:!?¡¿0-9]',
      unicode: true,
    );
    String limpio = texto.replaceAll(regex, '');
    limpio = limpio.replaceAll(RegExp(r'\n+'), '. ');
    limpio = limpio.replaceAll(RegExp(r'\s+'), ' ');
    return limpio.trim();
  }

  void dispose() {
    stop();
  }
}