class ApiConfig {
  // ── Desarrollo

  // Emulador Android → tu localhost
  static const String _devAndroid = 'http://10.0.2.2:8000';

  // Dispositivo físico → IP local de tu PC en la misma red WiFi
  static const String _devDevice = 'http://192.168.1.X:8000';

  // ── Producción
  static const String _prod = 'https://web-production-69011.up.railway.app';

  // ── Entorno Activo
  static const String baseUrl = _prod;

  // -- Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Timeout para todas las peticiones
  static const Duration timeout = Duration(seconds: 10);
}
