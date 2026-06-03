import 'package:hive/hive.dart';

part 'conversacion.g.dart';

@HiveType(typeId: 0)
class Conversacion extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String titulo;
  
  @HiveField(2)
  DateTime fecha;
  
  @HiveField(3)
  List<Map<String, String>> mensajes;
  
  Conversacion({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.mensajes,
  });
}