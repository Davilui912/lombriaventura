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

    _controller = VideoPlayerController.asset('assets/videos/anuncio.mp4');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          
          if (_controller != null && !_controller!.value.isInitialized && !_controller!.value.hasError) {
            _controller!.initialize().then((_) {
              _controller?.setLooping(true);
              _controller?.addListener(() {
                if (ctx.mounted && _controller != null) {
                  setState(() {}); 
                }
              });
              _controller?.play();
              if (ctx.mounted) {
                setState(() {});
              }
            }).catchError((error) {
              debugPrint("❌ ERROR AL INICIALIZAR EL VIDEO: $error");
            });
          }

          void cerrarAnuncio() {
            _controller?.pause();
            _controller?.dispose();
            _controller = null;
            if (ctx.mounted) Navigator.pop(ctx);
          }

          return WillPopScope(
            onWillPop: () async {
              cerrarAnuncio();
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
                    
                    // ✅ CAMBIO 1: Bloqueamos el espacio del video a 16:9 desde el inicio
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9, // Mantiene el marco fijo sin importar si cargó o no
                        child: Container(
                          color: Colors.black,
                          child: (_controller != null && _controller!.value.isInitialized)
                              ? VideoPlayer(_controller!)
                              : const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // ✅ CAMBIO 2: Protegemos los controles forzando una altura estricta
                    if (_controller != null && _controller!.value.isInitialized)
                      SizedBox(
                        height: 48, // Altura fija para evitar el error 'hasSize: is not true'
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: AppTheme.verde,
                              ),
                              onPressed: () {
                                if (_controller != null) {
                                  _controller!.value.isPlaying
                                      ? _controller!.pause()
                                      : _controller!.play();
                                  setState(() {});
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 10, // Le decimos a la barra exactamente cuánto medir de alto
                                child: VideoProgressIndicator(
                                  _controller!,
                                  allowScrubbing: true,
                                  colors: const VideoProgressColors(
                                    playedColor: AppTheme.verde,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                          onPressed: cerrarAnuncio,
                          child: const Text('Omitir'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            cerrarAnuncio();
                            marcarComoMostrado();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Gracias por ver el anuncio! +10 monedas 🪙'),
                                backgroundColor: AppTheme.verde,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.verde,
                            minimumSize: const Size(120, 45), 
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