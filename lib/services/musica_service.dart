import 'package:audioplayers/audioplayers.dart';

class MusicaService {
  static final MusicaService _instance = MusicaService._internal();
  factory MusicaService() => _instance;
  MusicaService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> iniciarMusica(String assetPath) async {
    if (_isPlaying) return;
    try {
      await _player.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
      _player.setReleaseMode(ReleaseMode.loop);
      _isPlaying = true;
    } catch (e) {
      print('Error al reproducir música: $e');
    }
  }

  Future<void> detenerMusica() async {
    if (!_isPlaying) return;
    await _player.stop();
    _isPlaying = false;
  }

  bool get estaReproduciendo => _isPlaying;

  void dispose() {
    _player.dispose();
  }
}