import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ComparaCompostaScreen extends StatelessWidget {
  const ComparaCompostaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 ¿Cómo va mi composta?'),
        backgroundColor: AppTheme.verde,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Sabes reconocer si tu composta está sana o necesita ayuda?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Observa estas imágenes y compara con tu composta.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // ✅ COMPOSTA SANA
            _buildTarjetaComparativa(
              titulo: '✅ Composta Sana',
              descripcion: '• Color oscuro y uniforme\n'
                  '• Olor a tierra húmeda\n'
                  '• Textura esponjosa\n'
                  '• Lombrices activas\n'
                  '• Sin moscas ni malos olores',
              imagen: 'assets/images/composta_sana.png',
              color: AppTheme.verde,
            ),

            const SizedBox(height: 20),

            // ✅ COMPOSTA NO SANA
            _buildTarjetaComparativa(
              titulo: '⚠️ Composta No Sana',
              descripcion: '• Color grisáceo o verdoso\n'
                  '• Olor a podrido o amoniaco\n'
                  '• Textura pegajosa o seca\n'
                  '• Lombrices muertas o ausentes\n'
                  '• Presencia de moscas o moho',
              imagen: 'assets/images/composta_no_sana.png',
              color: Colors.red,
            ),

            const SizedBox(height: 24),

            // ✅ CONSEJOS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.amarillo.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.amarillo),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 ¿Qué hacer si está no sana?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Si está seca: rocía agua\n'
                    '• Si está muy húmeda: agrega material seco (cartón, hojas)\n'
                    '• Si huele mal: agrega más material seco y remueve\n'
                    '• Si hay moscas: cubre bien la composta',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaComparativa({
    required String titulo,
    required String descripcion,
    required String imagen,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          // ✅ Imagen
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
              image: DecorationImage(
                image: AssetImage(imagen),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8),
              child: Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            descripcion,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}