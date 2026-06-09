class Accesorio {
  final String id;
  final String nombre;
  final String imagen;
  final int precio;
  bool comprado;
  bool equipado;

  Accesorio({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.precio,
    this.comprado = false,
    this.equipado = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'imagen': imagen,
      'precio': precio,
      'comprado': comprado,
      'equipado': equipado,
    };
  }

  factory Accesorio.fromMap(Map<String, dynamic> map) {
    return Accesorio(
      id: map['id'],
      nombre: map['nombre'],
      imagen: map['imagen'],
      precio: map['precio'],
      comprado: map['comprado'] ?? false,
      equipado: map['equipado'] ?? false,
    );
  }
}