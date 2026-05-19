import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive para almacenamiento local
  await Hive.initFlutter();
  
  // Abrir cajas de datos
  await Hive.openBox('logros');
  await Hive.openBox('diario');
  await Hive.openBox('configuracion');
  await Hive.openBox('chat_historial');
  await Hive.openBox('actividad');
  
  runApp(const LombiAventuraApp());
}

class LombiAventuraApp extends StatelessWidget {
  const LombiAventuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LombiAventura',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}