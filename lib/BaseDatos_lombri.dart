import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton: solo existe una instancia de DatabaseHelper en toda la app
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  // Getter que abre la base solo la primera vez y reutiliza la misma conexión
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'lombriaventura.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id    INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT    NOT NULL,
            edad  INTEGER
          )
        ''');
      },
    );
  }

  // Insertar un usuario
  Future<void> addUsuario(String nombre, int edad) async {
    final db = await database;
    await db.insert(
      'usuarios',
      {'nombre': nombre, 'edad': edad},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Usuario agregado: $nombre');
  }

  // Consultar todos los usuarios
  Future<void> mostrarUsuarios() async {
    final db = await database;
    final data = await db.query('usuarios');
    print(data);
  }
}
