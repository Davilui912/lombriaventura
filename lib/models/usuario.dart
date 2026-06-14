class Usuario {
  final String nombre;
  final String email;
  final String password;
  final int edad;
  final String ciudad;
  final DateTime fechaRegistro;

  Usuario({
    required this.nombre,
    required this.email,
    required this.password,
    required this.edad,
    required this.ciudad,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'password': password,
      'edad': edad,
      'ciudad': ciudad,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      nombre: map['nombre'],
      email: map['email'],
      password: map['password'],
      edad: map['edad'],
      ciudad: map['ciudad'],
      fechaRegistro: DateTime.parse(map['fechaRegistro']),
    );
  }
}