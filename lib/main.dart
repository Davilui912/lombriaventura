import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'screens/login_screen.dart';
import 'models/conversacion.dart';
import 'services/recordatorios_service.dart';
import 'screens/splash_screen.dart';
import 'screens/privacidad_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

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
  await Hive.openBox('usuarios');
  await Hive.openBox('historial_ventas');

  final recordatorioService = RecordatoriosService();
  await recordatorioService.init();

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
      home: const SplashScreen(),
    );
  }
}