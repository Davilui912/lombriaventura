class Reto {
  final String id;
  final String titulo;
  final String descripcion;
  final String emoji;
  bool completado;
  final int orden;

  Reto({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.emoji,
    this.completado = false,
    required this.orden,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'emoji': emoji,
      'completado': completado,
      'orden': orden,
    };
  }

  factory Reto.fromMap(Map<String, dynamic> map) {
    return Reto(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      emoji: map['emoji'],
      completado: map['completado'] ?? false,
      orden: map['orden'],
    );
  }
}