class ProductoTienda {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagen; // emoji por ahora
  final List<String> incluye;

  ProductoTienda({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.incluye,
  });
}