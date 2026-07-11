import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/theme.dart';
import 'registro_screen.dart';

class PrivacidadScreen extends StatefulWidget {
  const PrivacidadScreen({super.key});

  @override
  State<PrivacidadScreen> createState() => _PrivacidadScreenState();
}

class _PrivacidadScreenState extends State<PrivacidadScreen> {
  bool _aceptado = false;
  final bool _mostrarTextoCompleto = false;

  @override
  void initState() {
    super.initState();
    _verificarAceptacion();
  }

  Future<void> _verificarAceptacion() async {
    final box = await Hive.openBox('configuracion');
    final aceptado = box.get('privacidad_aceptada', defaultValue: false);
    if (aceptado) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegistroScreen()),
        );
      }
    }
  }

  Future<void> _aceptar() async {
    if (_aceptado) {
      final box = await Hive.openBox('configuracion');
      await box.put('privacidad_aceptada', true);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegistroScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔒 Aviso de Privacidad'),
        backgroundColor: AppTheme.verde,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Aviso de Privacidad',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.verde,
              ),
            ),
            const SizedBox(height: 16),
            
            // ✅ Texto completo del aviso
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '👤 ¿Qué información recopilamos?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Nombre completo\n'
                    '• Nombre de usuario\n'
                    '• Edad\n'
                    '• Ciudad de residencia\n'
                    '• Género (Lola/Lalo)\n'
                    '• Respuesta de seguridad (para recuperar cuenta)',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    '🔐 ¿Cómo usamos tu información?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Para personalizar tu experiencia en la app\n'
                    '• Para guardar tu progreso y logros\n'
                    '• Para mostrarte el personaje que elegiste\n'
                    '• Para ayudarte a recuperar tu cuenta si olvidas tu contraseña',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    '🛡️ ¿Cómo protegemos tus datos?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Tus datos se guardan de forma segura\n'
                    '• No compartimos tu información con terceros\n'
                    '• Solo usamos tu información dentro de la app\n'
                    '• Puedes solicitar eliminar tus datos en cualquier momento',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    '👨‍👩‍👦 Consentimiento de los padres',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Esta app está diseñada para niños, pero la información personal '
                    'solo se recopila con el consentimiento de los padres o tutores. '
                    'Al aceptar, confirmas que tienes la autorización de tus padres '
                    'para usar esta app y proporcionar tu información.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    '📧 Contacto',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Si tienes preguntas sobre tu privacidad, contáctanos en:\n'
                    '📧 privacidad@lombriaventura.com',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ✅ Checkbox de aceptación
            Row(
              children: [
                Checkbox(
                  value: _aceptado,
                  onChanged: (value) {
                    setState(() {
                      _aceptado = value ?? false;
                    });
                  },
                  activeColor: AppTheme.verde,
                ),
                const Expanded(
                  child: Text(
                    'He leído y acepto el Aviso de Privacidad y el tratamiento de mis datos personales.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // ✅ Botón continuar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _aceptado ? _aceptar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verde,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continuar al registro',
                  style: TextStyle(
                    fontSize: 18,
                    color: _aceptado ? Colors.white : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}