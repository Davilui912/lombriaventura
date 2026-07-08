import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'models/conversacion.dart';
import 'services/recordatorios_service.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart'; // ← necesario para Firebase.initializeApp

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase con opciones explícitas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive — solo para datos locales simples
  await Hive.initFlutter();
  Hive.registerAdapter(ConversacionAdapter());

  // Cajas de Hive: úsalas solo para caché rápido y configuración local
  // Las entidades principales (logros, diario, usuarios, etc.) viven en PostgreSQL
  await Hive.openBox('configuracion');
  await Hive.openBox('chat_historial');
  await Hive.openBox('accesorios');
  await Hive.openBox('logros');
  await Hive.openBox('diario');
  await Hive.openBox('actividad');
  await Hive.openBox('recordatorios');
  await Hive.openBox('monedas');
  await Hive.openBox('capacitaciones');
  await Hive.openBox('usuarios');
  await Hive.openBox('historial_ventas');

  final recordatorioService = RecordatoriosService();
  await recordatorioService.init();

  runApp(
      const LombriaventuraApp()); // ← espacio correcto entre const y el widget
}

class LombriaventuraApp extends StatelessWidget {
  const LombriaventuraApp({super.key}); // ← constructor primero

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lombriaventura',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
