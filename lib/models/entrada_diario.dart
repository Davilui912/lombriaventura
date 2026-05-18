class EntradaDiario {
  final String id;
  final DateTime fecha;
  final String? nota;
  final List<String> fotosRutas; // Rutas locales de las fotos
  final String estado; // 😊 Excelente, 😐 Regular, 😟 Necesita ayuda

  EntradaDiario({
    required this.id,
    required this.fecha,
    this.nota,
    this.fotosRutas = const [],
    this.estado = '😊',
  });

  // Convertir a Map para guardar en Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'nota': nota,
      'fotosRutas': fotosRutas,
      'estado': estado,
    };
  }

  // Crear desde Map (al leer de Hive)
  factory EntradaDiario.fromMap(Map<String, dynamic> map) {
    return EntradaDiario(
      id: map['id'],
      fecha: DateTime.parse(map['fecha']),
      nota: map['nota'],
      fotosRutas: List<String>.from(map['fotosRutas'] ?? []),
      estado: map['estado'] ?? '😊',
    );
  }
}