import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../config/theme.dart';

class AnuncioService {
  static bool _anuncioMostradoHoy = false;
  static String _ultimaFecha = '';
  static VideoPlayerController? _controller;

  static bool debeMostrarAnuncio() {
    final hoy = DateTime.now().toString().substring(0, 10);
    if (_ultimaFecha != hoy) {
      _ultimaFecha = hoy;
      _anuncioMostradoHoy = false;
    }
    return !_anuncioMostradoHoy;
  }

  static void marcarComoMostrado() {
    _anuncioMostradoHoy = true;
    _ultimaFecha = DateTime.now().toString().substring(0, 10);
  }

  static Future<void> mostrarAnuncio(BuildContext context) async {
    if (!debeMostrarAnuncio()) return;

    // ✅ 1. Inicializamos el controlador y guardamos el proceso en un Future
    _controller = VideoPlayerController.asset('assets/videos/anuncio.mp4');
    
    // Almacenamos el Future de la inicialización para dárselo al FutureBuilder
    final Future<void> inicializarVideo = _controller!.initialize().then((_) {
      _controller!.setLooping(true);
      _controller!.play(); // Empieza a reproducirse en cuanto carga
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return WillPopScope(
            onWillPop: () async {
              _controller?.pause();
              _controller?.dispose();
              _controller = null;
              return true;
            },
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ 2. REPRODUCTOR DE VIDEO CON FUTUREBUILDER REAL
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black, // El fondo mientras carga
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FutureBuilder(
                          future: inicializarVideo,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              // ✅ 3. ASPECT RATIO: La clave para que se vea el video
                              return AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ✅ Controles de reproducción mostrados solo cuando está listo
                    FutureBuilder(
                      future: inicializarVideo,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: AppTheme.verde,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _controller!.value.isPlaying
                                        ? _controller!.pause()
                                        : _controller!.play();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: VideoProgressIndicator(
                                  _controller!,
                                  allowScrubbing: true,
                                  colors: VideoProgressColors(
                                    playedColor: AppTheme.verde,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink(); // Oculta controles mientras carga el video
                      }
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🌟 ¡Mira este video!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Aprende más sobre lombricomposta',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            _controller?.pause();
                            _controller?.dispose();
                            _controller = null;
                            Navigator.pop(ctx);
                          },
                          child: const Text('Omitir'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _controller?.pause();
                            _controller?.dispose();
                            _controller = null;
                            marcarComoMostrado();
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Gracias por ver el anuncio! +10 monedas 🪙'),
                                backgroundColor: AppTheme.verde,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.verde,
                          ),
                          child: const Text('Ver ahora'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}