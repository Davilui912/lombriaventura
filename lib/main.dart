import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();

  // ==== ABRIR TODAS LAS CAJAS QUE NECESITAS ====
  await Hive.openBox('logros');
  await Hive.openBox('diario');
  await Hive.openBox('configuracion');
  await Hive.openBox('chat_historial');
  await Hive.openBox('actividad');      // ← AGREGAR (para ActividadService)
  await Hive.openBox('recordatorios');  // ← AGREGAR (para RecordatoriosService)
  await Hive.openBox('monedas');        // ← AGREGAR (para Tienda)

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