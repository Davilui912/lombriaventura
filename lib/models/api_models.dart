// USUARIO
class Usuario {
  final String uid;
  final String nombre;
  final String nombreUsuario;
  final String email;
  final int? edad;
  final String? ciudad;
  final String? genero;
  final int estrellas;
  final int monedas;
  final DateTime fechaRegistro;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.nombreUsuario,
    required this.email,
    this.edad,
    this.ciudad,
    this.genero,
    required this.estrellas,
    required this.monedas,
    required this.fechaRegistro,
  });

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        uid: j['uid'],
        nombre: j['nombre'],
        nombreUsuario: j['nombre_usuario'],
        email: j['email'],
        edad: j['edad'],
        ciudad: j['ciudad'],
        genero: j['genero'],
        estrellas: j['estrellas'] ?? 0,
        monedas: j['monedas'] ?? 0,
        fechaRegistro: DateTime.parse(j['fecha_registro']),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'nombre': nombre,
        'nombre_usuario': nombreUsuario,
        'email': email,
        if (edad != null) 'edad': edad,
        if (ciudad != null) 'ciudad': ciudad,
        if (genero != null) 'genero': genero,
      };
}

// DIARIO
class EntradaDiario {
  final int id;
  final String uid;
  final DateTime fecha;
  final String? nota;
  final String? estado;
  final String? temperatura;
  final String? tipoResiduo;
  final int? compostaPunos;
  final int? lixiviadoCucharadas;
  final List<String> fotos;

  EntradaDiario({
    required this.id,
    required this.uid,
    required this.fecha,
    this.nota,
    this.estado,
    this.temperatura,
    this.tipoResiduo,
    this.compostaPunos,
    this.lixiviadoCucharadas,
    this.fotos,
  });

  factory EntradaDiario.fromJson(Map<String, dynamic> j) => EntradaDiario(
        id: j['id'],
        uid: j['uid'],
        fecha: DateTime.parse(j['fecha']),
        nota: j['nota'],
        estado: j['estado'],
        temperatura: j['temperatura'],
        tipoResiduo: j['tipo_residuo'],
        compostaPunos: j['composta_punos'],
        lixiviadoCucharadas: j['lixiviado_cucharadas'],
        fotos: List<String>.from(j['fotos'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'id': id,
        if (nota != null) 'nota': nota,
        if (estado != null) 'estado': estado,
        if (temperatura != null) 'temperatura': temperatura,
        if (tipoResiduo != null) 'tipo_residuo': tipoResiduo,
        if (compostaPunos != null) 'composta_punos': compostaPunos,
        if (lixiviadoCucharadas != null)
          'lixiviado_cucharadas': lixiviadoCucharadas,
        'fotos': fotos,
      };
}

// VENTA
class Venta {
  final int id;
  final String uid;
  final String producto;
  final int cantidad;
  final double precioUnitario;
  final int totalGanado;
  final DateTime fecha;
  final String? descripcion;

  Venta({
    required this.id,
    required this.uid,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.totalGanado,
    required this.fecha,
    this.descripcion,
  });

  factory Venta.fromJson(Map<String, dynamic> j) => Venta(
        id: j['id'],
        uid: j['uid'],
        producto: j['producto'],
        cantidad: j['cantidad'],
        precioUnitario: (j['precio_unitario'] as num).toDouble(),
        totalGanado: j['total_ganado'],
        fecha: DateTime.parse(j['fecha']),
        descripcion: j['descripcion'],
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'producto': producto,
        'cantidad': cantidad,
        'precio_unitario': precioUnitario,
        'total_ganado': totalGanado,
        if (descripcion != null) 'descripcion': descripcion,
      };
}

// RETO
class Reto {
  final int id;
  final String uid;
  final String retoId;
  final bool completado;
  final DateTime? fechaCompletado;
  final int? medicion;
  final String? fotoUrl;

  Reto({
    required this.id,
    required this.uid,
    required this.retoId,
    required this.completado,
    this.fechaCompletado,
    this.medicion,
    this.fotoUrl,
  });

  factory Reto.fromJson(Map<String, dynamic> j) => Reto(
        id: j['id'],
        uid: j['uid'],
        retoId: j['reto_id'],
        completado: j['completado'] ?? false,
        fechaCompletado: j['fecha_completado'] != null
            ? DateTime.parse(j['fecha_completado'])
            : null,
        medicion: j['medicion'],
        fotoUrl: j['foto_url'],
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'reto_id': retoId,
        'completado': completado,
        if (medicion != null) 'medicion': medicion,
        if (fotoUrl != null) 'foto_url': fotoUrl,
        if (descripcion != null) 'descripcion': descripcion,
      };
}

// LOGRO
class Logro {
  final int id;
  final String uid;
  final String tipo;
  final String nombre;
  final String? descripcion;
  final DateTime fechaDesbloqueo;

  Logro({
    required this.id,
    required this.uid,
    required this.tipo,
    required this.nombre,
    this.descripcion,
    required this.fechaDesbloqueo,
  });

  factory Logro.fromJson(Map<String, dynamic> j) => Logro(
        id: j['id'],
        uid: j['uid'],
        tipo: j['tipo'],
        nombre: j['nombre'],
        descripcion: j['descripcion'],
        fechaDesbloqueo: DateTime.parse(j['fecha_desbloqueo']),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'tipo': tipo,
        'nombre': nombre,
        if (descripcion != null) 'descripcion': descripcion,
      };
}

// RECORDATORIO
class Recordatorio {
  final int id;
  final String uid;
  final String titulo;
  final String? mensaje;
  final DateTime fecha;
  final bool visto;

  Recordatorio({
    required this.id,
    required this.uid,
    required this.titulo,
    this.mensaje,
    required this.fecha,
    required this.visto,
  });

  factory Recordatorio.fromJson(Map<String, dynamic> j) => Recordatorio(
        id: j['id'],
        uid: j['uid'],
        titulo: j['titulo'],
        mensaje: j['mensaje'],
        fecha: DateTime.parse(j['fecha']),
        visto: j['visto'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'titulo': titulo,
        if (mensaje != null) 'mensaje': mensaje,
      };
}

// CAPACITACION
class Capacitacion {
  final int id;
  final String uid;
  final String nombreCapacitado;
  final int? edadCapacitado;
  final String? municipio;
  final String? estado;
  final String? pais;
  final String? invitadoPor;
  final int monedasGanadas;
  final DateTime fecha;

  Capacitacion({
    required this.id,
    required this.uid,
    required this.nombreCapacitado,
    this.edadCapacitado,
    this.municipio,
    this.estado,
    this.pais,
    this.invitadoPor,
    required this.monedasGanadas,
    required this.fecha,
  });

  factory Capacitacion.fromJson(Map<String, dynamic> j) => Capacitacion(
        id: j['id'],
        uid: j['uid'],
        nombreCapacitado: j['nombre_capacitado'],
        edadCapacitado: j['edad_capacitado'],
        municipio: j['municipio'],
        estado: j['estado'],
        pais: j['pais'],
        invitadoPor: j['invitado_por'],
        monedasGanadas: j['monedas_ganadas'] ?? 50,
        fecha: DateTime.parse(j['fecha']),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'nombre_capacitado': nombreCapacitado,
        if (edadCapacitado != null) 'edad_capacitado': edadCapacitado,
        if (municipio != null) 'municipio': municipio,
        if (estado != null) 'estado': estado,
        if (pais != null) 'pais': pais,
        if (invitadoPor != null) 'invitado_por': invitadoPor,
      };
}
