import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/theme.dart';
import 'screens/login_screen.dart';
import 'models/conversacion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
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