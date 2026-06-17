import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/theme.dart';
import 'screens/login_screen.dart';
import 'models/conversacion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // ✅ Registrar versión de la base de datos
  final box = await Hive.openBox('configuracion');
  final versionActual = box.get('db_version', defaultValue: 0);
  const versionNueva = 1;
  
  if (versionActual < versionNueva) {
    // Si la versión es antigua, borrar datos para evitar errores
    print('🔄 Actualizando base de datos de la versión $versionActual a $versionNueva');
    await box.clear();
    await box.put('db_version', versionNueva);
    print('✅ Base de datos actualizada');
  }

  Hive.registerAdapter(ConversacionAdapter());
  
  await Hive.openBox('logros');
  await Hive.openBox('diario');
  await Hive.openBox('configuracion');
  await Hive.openBox('chat_historial');
  await Hive.openBox('actividad');
  await Hive.openBox('recordatorios');
  await Hive.openBox('monedas');
  await Hive.openBox('accesorios');
  await Hive.openBox('capacitaciones');
  await Hive.openBox('usuarios');  // ← NUEVO

  runApp(const LombriaventuraApp());
}

class LombriaventuraApp extends StatelessWidget {
  const LombriaventuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lombriaventura',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),  // ← Login con email/contraseña
    );
  }
}