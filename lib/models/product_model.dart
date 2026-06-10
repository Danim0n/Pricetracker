class Product {
  final int id;
  final String nombre;
  final String urlTienda;
  final String imagenUrl;
  final double precioActual;

  Product({
    required this.id,
    required this.nombre,
    required this.urlTienda,
    required this.imagenUrl,
    required this.precioActual,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nombre: json['nombre'],
      urlTienda: json['url_tienda'],
      imagenUrl: json['imagen_url'],
      precioActual: (json['precio_actual'] as num).toDouble(),
    );
  }
}
