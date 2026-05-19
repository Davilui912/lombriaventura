import '../models/producto_tienda.dart';

class TiendaService {
  // Producto principal: Kit de lombricomposta
  ProductoTienda obtenerKitBasico() {
    return ProductoTienda(
      id: 'kit_basico',
      nombre: 'Kit Básico de Lombricomposta',
      descripcion: 'Todo lo que necesitas para empezar tu propia lombricomposta en casa. '
          '¡Las lombrices hacen todo el trabajo!',
      precio: 299.00, // Precio en MXN
      imagen: '🪱',
      incluye: [
        'Contenedor especial con tapa',
        '50 Lombrices californianas',
        'Fibra de coco (sustrato)',
        'Tierra preparada',
        'Manual ilustrado paso a paso',
        'Guía de cuidados',
      ],
    );
  }

  // Futuros productos
  List<ProductoTienda> obtenerProductos() {
    return [
      obtenerKitBasico(),
      ProductoTienda(
        id: 'lombrices_extra',
        nombre: 'Paquete de Lombrices Extra',
        descripcion: '100 lombrices californianas adicionales para tu composta.',
        precio: 149.00,
        imagen: '🪱',
        incluye: [
          '100 Lombrices californianas',
          'Guía de aclimatación',
        ],
      ),
      ProductoTienda(
        id: 'sustrato',
        nombre: 'Fibra de Coco Premium',
        descripcion: 'Sustrato extra para mantener felices a tus lombrices.',
        precio: 89.00,
        imagen: '🥥',
        incluye: [
          '2 kg de fibra de coco',
          'Instrucciones de uso',
        ],
      ),
    ];
  }
}