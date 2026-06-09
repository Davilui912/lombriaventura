import 'package:flutter/material.dart';

class PersonajeConAccesorios extends StatelessWidget {
  final String personaje;
  final String? gorraEquipada;
  final String? lentesEquipados;
  final String? collarEquipado;
  final String? sombreroEquipado;
  final double size;

  const PersonajeConAccesorios({
    super.key,
    required this.personaje,
    this.gorraEquipada,
    this.lentesEquipados,
    this.collarEquipado,
    this.sombreroEquipado,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Imagen base
          Positioned.fill(
            child: Image.asset(
              'assets/images/personajes/${personaje.toLowerCase()}_base.png',
              fit: BoxFit.contain,
            ),
          ),
          // Sombrero
          if (sombreroEquipado != null)
            Positioned(
              top: size * 0.0,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/accesorios/$sombreroEquipado',
                  width: size * 0.7,
                  height: size * 0.3,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          // Gorra
          if (gorraEquipada != null && sombreroEquipado == null)
            Positioned(
              top: size * 0.05,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/accesorios/$gorraEquipada',
                  width: size * 0.6,
                  height: size * 0.25,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          // Lentes
          if (lentesEquipados != null)
            Positioned(
              top: size * 0.35,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/accesorios/$lentesEquipados',
                  width: size * 0.55,
                  height: size * 0.15,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          // Collar
          if (collarEquipado != null)
            Positioned(
              top: size * 0.55,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/accesorios/$collarEquipado',
                  width: size * 0.5,
                  height: size * 0.12,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}