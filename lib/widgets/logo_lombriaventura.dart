import 'package:flutter/material.dart';

class LogoLombriaventura extends StatelessWidget {
  final double size;
  final bool mostrarTexto;

  const LogoLombriaventura({
    super.key,
    this.size = 80,
    this.mostrarTexto = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo circular con la imagen
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: AssetImage('assets/images/logo_lombriaventura.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
        // Texto opcional debajo del logo
        if (mostrarTexto) ...[
          const SizedBox(height: 8),
          const Text(
            'Lombriaventura',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7AC943),
            ),
          ),
        ],
      ],
    );
  }
}