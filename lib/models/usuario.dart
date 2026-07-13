
class Usuario {
  final String uid;
  final String nombre;
  final String nombreUsuario;
  final String email;
  final String password; 
  final int? edad;
  final String? ciudad;
  final String? genero;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.nombreUsuario,
    required this.email,
    required this.password, 
    this.edad,
    this.ciudad,
    this.genero,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      uid: json['uid'] ?? '',
      nombre: json['nombre'] ?? '',
      nombreUsuario: json['nombre_usuario'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '', 
      edad: json['edad'],
      ciudad: json['ciudad'],
      genero: json['genero'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nombre': nombre,
      'nombre_usuario': nombreUsuario,
      'email': email,
      'password': password, 
      if (edad != null) 'edad': edad,
      if (ciudad != null) 'ciudad': ciudad,
      if (genero != null) 'genero': genero,
    };
  }
}