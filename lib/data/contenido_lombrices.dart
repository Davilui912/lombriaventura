import 'package:flutter/material.dart';

class LeccionLombriz {
  final String titulo;
  final String contenido;
  final IconData icono;
  final List<String>? datosCuriosos;

  LeccionLombriz({
    required this.titulo,
    required this.contenido,
    required this.icono,
    this.datosCuriosos,
  });
}

final List<LeccionLombriz> leccionesLombrices = [
  LeccionLombriz(
    titulo: '¿Qué es la lombriz roja californiana?',
    contenido: 'Es una lombriz especial que come residuos orgánicos y los convierte en humus, un abono súper nutritivo para las plantas. ¡Es como una pequeña fábrica de tierra fértil!',
    icono: Icons.bug_report,
    datosCuriosos: ['Viven hasta 15 años', 'Pueden comer la mitad de su peso cada día'],
  ),
  LeccionLombriz(
    titulo: '¿Cómo nacen las lombrices?',
    contenido: 'Las lombrices se juntan en pareja y comparten una parte especial de su cuerpo. Ponen pequeños huevitos en el suelo dentro de capullos muy chiquitos. ¡Cada 10 días producen un capullo! De cada capullo pueden nacer entre 2 y 5 lombrices bebés.',
    icono: Icons.favorite,
    datosCuriosos: ['Las bebés tardan 2-3 meses en ser adultas', 'Las adultas tienen un anillo en su cuerpo'],
  ),
  LeccionLombriz(
    titulo: '¿Qué comen las lombrices?',
    contenido: 'Les encantan las cáscaras de frutas y verduras (cortadas en trozos pequeños), restos de café y té, hojas secas, pasto, cartón y papel sin tinta, y cáscara de huevo triturada.',
    icono: Icons.restaurant,
    datosCuriosos: ['No comen residuos frescos, esperan días a que fermenten', 'No tienen dientes, por eso hay que cortar la comida chiquito'],
  ),
  LeccionLombriz(
    titulo: '¿Qué NO pueden comer?',
    contenido: 'Nada de carnes, huesos, lácteos, cítricos en exceso, sal, aceites, grasas, plásticos o materiales químicos. ¡Eso las enferma o las puede matar!',
    icono: Icons.warning,
    datosCuriosos: ['Los cítricos dañan su piel permeable', 'La comida grasosa tapa el suelo y genera malos olores'],
  ),
  LeccionLombriz(
    titulo: '¿Dónde viven felices?',
    contenido: 'Necesitan un hogar con temperatura entre 15°C y 25°C. Si hace mucho calor o mucho frío, pueden morir. También necesitan humedad: ni mucho agua, ni muy seco.',
    icono: Icons.home,
    datosCuriosos: ['Soportan entre 10°C y 35°C, pero es límite', 'La "prueba del puño" ayuda a saber si la humedad está bien'],
  ),
];