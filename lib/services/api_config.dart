// Emulador Android → déjalo así
static const String baseUrl = _devAndroid; // http://10.0.2.2:8000

// Dispositivo físico → cambia la IP de tu PC
static const String _devDevice = 'http://192.168.1.X:8000';

/// Configuración central de la API.
/// Cambiar [baseUrl] cuando se despliegue en la nube.
class ApiConfig {
  // ── Desarrollo ──────────────────────────────────────────────────
  // Emulador Android → tu localhost
  static const String _devAndroid = 'http://10.0.2.2:8000';
  // Dispositivo físico → IP local de tu PC en la misma red WiFi
  static const String _devDevice = 'http://192.168.1.X:8000'; // ← cambia X

  // ── Producción ──────────────────────────────────────────────────
  static const String _prod = 'https://tu-api.railway.app'; // ← cuando sesuba a la nube

  // ── Activo ──────────────────────────────────────────────────────
  // Cambiar esto según donde se esté probando:
  static const String baseUrl = _devAndroid;

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Timeout para todas las peticiones
  static const Duration timeout = Duration(seconds: 10);
}