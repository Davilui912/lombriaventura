class EntradaDiario {
  final String id;
  final DateTime fecha;
  final String? nota;
  final List<String> fotosRutas;
  final String estado; // 😊 😐 😟

  // NUEVOS CAMPOS
  final int? humedad; // 1-10 (qué tan húmeda está)
  final String? temperatura; // ❄️ Frío / 🌤️ Buen clima / ☀️ Caliente (CAMBIADO)
  final String? tipoResiduo; // "Frutas", "Verduras", "Café", "Mixto"
  final double? produccionComposta; // gramos
  final double? produccionLixiviado; // mililitros

  EntradaDiario({
    required this.id,
    required this.fecha,
    this.nota,
    this.fotosRutas = const [],
    this.estado = '😊',
    this.humedad,
    this.temperatura,
    this.tipoResiduo,
    this.produccionComposta,
    this.produccionLixiviado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'nota': nota,
      'fotosRutas': fotosRutas,
      'estado': estado,
      'humedad': humedad,
      'temperatura': temperatura,
      'tipoResiduo': tipoResiduo,
      'produccionComposta': produccionComposta,
      'produccionLixiviado': produccionLixiviado,
    };
  }

  factory EntradaDiario.fromMap(Map<String, dynamic> map) {
    return EntradaDiario(
      id: map['id'],
      fecha: DateTime.parse(map['fecha']),
      nota: map['nota'],
      fotosRutas: List<String>.from(map['fotosRutas'] ?? []),
      estado: map['estado'] ?? '😊',
      humedad: map['humedad'],
      temperatura: map['temperatura'],
      tipoResiduo: map['tipoResiduo'],
      produccionComposta: map['produccionComposta'],
      produccionLixiviado: map['produccionLixiviado'],
    );
  }
}