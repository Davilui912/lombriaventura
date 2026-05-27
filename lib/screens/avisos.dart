import 'package:flutter/material.dart';
import '../config/theme.dart';

class AvisosScreen extends StatelessWidget {
  const AvisosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚠️ Avisos Importantes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Encabezado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.withValues(alpha: 0.2), Colors.red.withValues(alpha: 0.1)],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Text('⚠️', style: TextStyle(fontSize: 35)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lee con atención.\n¡Tus lombrices dependen de ti!',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.cafe),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Aviso 1: Temperatura
          _buildAviso(
            icono: '🌡️',
            titulo: 'Temperatura ideal',
            color: Colors.orange,
            contenido: 'Las lombrices rojas californianas viven felices entre 15°C y 25°C.\n\n'
                '🔥 Si hace más de 35°C, pueden MORIR. Busca un lugar fresco y con sombra.\n\n'
                '❄️ Si baja de 5°C, dejan de comer y pueden MORIR. En invierno, mete el bote a casa o cúbrelo con una manta vieja.\n\n'
                '🏠 El mejor lugar: cochera, lavandería o un rincón techado del patio.',
          ),

          // Aviso 2: Amoníaco
          _buildAviso(
            icono: '👃',
            titulo: 'Cuidado con el amoníaco',
            color: Colors.red,
            contenido: 'Si tu composta huele a PIPÍ o a limpiador de pisos, ¡algo va mal!\n\n'
                'Eso es AMONÍACO. Se produce cuando hay demasiados restos de comida (nitrógeno) y poco material seco (carbono).\n\n'
                '✅ SOLUCIÓN FÁCIL:\n'
                '1. Deja de darles comida por una semana.\n'
                '2. Agrega cartón sin tinta, hojas secas o papel periódico picado.\n'
                '3. Revuelve suavemente para que respire.\n\n'
                '👃 ¿Cómo detectarlo sin herramientas? Simplemente huele. Si no huele a tierra fresca, algo pasa.',
          ),

          // Aviso 3: Hongos
          _buildAviso(
            icono: '🍄',
            titulo: 'Hongos en la composta',
            color: Colors.brown,
            contenido: '¡No todos los hongos son malos!\n\n'
                '✅ HONGOS BUENOS (no hagas nada):\n'
                '• Blancos y peludos: son normales, ayudan a descomponer.\n'
                '• Pequeños y grises: son parte del proceso.\n\n'
                '❌ HONGOS MALOS (actúa rápido):\n'
                '• Verdes, negros o naranjas: hay demasiada humedad.\n'
                '• SOLUCIÓN: Destapa el bote para que se ventile, no riegues por 3-4 días y agrega cartón seco.\n\n'
                '🔍 Los niños pueden identificarlos por el COLOR. Si no es blanco, avisa a un adulto.',
          ),

          // Aviso 4: Apareo
          _buildAviso(
            icono: '🐣',
            titulo: 'Apareo por temporadas',
            color: Colors.pink,
            contenido: 'Las lombrices tienen temporadas de apareo, como muchos animales.\n\n'
                '🌸 PRIMAVERA y 🍂 OTOÑO: Se reproducen más. Verás bolitas pequeñas color café claro (huevos). ¡Cada huevo tiene 3-5 lombrices bebé!\n\n'
                '☀️ VERANO (mucho calor) y ❄️ INVIERNO (mucho frío): Dejan de reproducirse para sobrevivir. ¡Es normal!\n\n'
                '🐛 Las lombrices bebé son blancas al nacer y se vuelven rojas en unos días. No las toques, son muy frágiles.\n\n'
                '⏳ Paciencia: Una población tarda 3-6 meses en duplicarse.',
          ),

          // Aviso 5: No sacar las lombrices
          _buildAviso(
            icono: '🚫',
            titulo: '¡No saques las lombrices!',
            color: Colors.red,
            contenido: 'Las lombrices son muy sensibles y pueden MORIR si las expones.\n\n'
                '❌ NUNCA:\n'
                '• Sacarlas al sol directo (se deshidratan en minutos).\n'
                '• Tocarlas con las manos secas (su piel necesita humedad).\n'
                '• Usar químicos, jabones o insecticidas cerca del bote.\n'
                '• Dejarlas sin comida por más de 2 semanas.\n'
                '• Mojarlas con agua con cloro.\n\n'
                '✅ SIEMPRE:\n'
                '• Mójate las manos antes de tocarlas.\n'
                '• Regrésalas rápido a su cama.\n'
                '• Mantén el bote tapado y en sombra.\n\n'
                '🐛 Ellas trabajan bajo tierra. ¡Déjalas tranquilas y te darán el mejor abono!',
          ),

          // Aviso 6: Protección climática
          _buildAviso(
            icono: '☀️',
            titulo: 'Protección contra el clima',
            color: Colors.blue,
            contenido: 'Tu bote de composta debe estar protegido de:\n\n'
                '☀️ SOL DIRECTO: Cocina a las lombrices. Siempre en sombra.\n\n'
                '🌧️ LLUVIA: Si entra agua de más, se ahogan. Ponle tapa o techo.\n\n'
                '❄️ FRÍO EXTREMO: Mete el bote a casa o cúbrelo con cartón grueso.\n\n'
                '🌬️ VIENTO FUERTE: Puede voltear el bote. Ponlo en un rincón protegido.\n\n'
                '🏠 RECOMENDACIÓN: El mejor lugar es un rincón techado, fresco en verano y protegido en invierno.',
          ),

          // Aviso 7: Construcción del bote (PENDIENTE)
          _buildAviso(
            icono: '🪣',
            titulo: 'Construir tu bote (PRÓXIMAMENTE)',
            color: Colors.grey,
            contenido: 'Estamos preparando una guía paso a paso para que construyas tu propio bote de lombricomposta.\n\n'
                '👨‍👩‍👧 Necesitarás ayuda de un adulto.\n\n'
                '📋 Materiales que necesitarás (los confirmaremos pronto):\n'
                '• Contenedor de plástico con tapa\n'
                '• Taladro para hacer agujeros\n'
                '• Fibra de coco o tierra\n'
                '• Y por supuesto... ¡lombrices!\n\n'
                '🔔 Te avisaremos cuando esté lista esta sección.',
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAviso({
    required String icono,
    required String titulo,
    required Color color,
    required String contenido,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(icono, style: const TextStyle(fontSize: 24))),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.cafe),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              contenido,
              style: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.cafe),
            ),
          ),
        ],
      ),
    );
  }
}