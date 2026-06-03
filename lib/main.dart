import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';
import 'models/conversacion.dart';
import 'services/conversacion_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();
  
  // Registrar el adaptador de conversación
  Hive.registerAdapter(ConversacionAdapter());

  // ==== ABRIR TODAS LAS CAJAS QUE NECESITAS ====
  await Hive.openBox('logros');
  await Hive.openBox('diario');
  await Hive.openBox('configuracion');
  await Hive.openBox('chat_historial');
  await Hive.openBox('actividad');
  await Hive.openBox('recordatorios');
  await Hive.openBox('monedas');
  
  // ✅ Abrir la caja de conversaciones (importante: await)
  await Hive.openBox<Conversacion>('conversaciones');

  runApp(const LombriAventuraApp());
}

class LombriAventuraApp extends StatelessWidget {
  const LombriAventuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LombriAventura',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}