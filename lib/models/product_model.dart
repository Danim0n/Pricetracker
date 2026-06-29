class Product {
  final int id;
  final String nombre;
  final String urlTienda;
  final String imagenUrl;
  final double precioActual;
  final double precioOriginal;

  Product({
    required this.id,
    required this.nombre,
    required this.urlTienda,
    required this.imagenUrl,
    required this.precioActual,
    required this.precioOriginal,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      nombre: json['nombre'].toString(),
      urlTienda: json['url_tienda'].toString(),
      imagenUrl: json['imagen_url'].toString(),
      precioActual: (json['precio_actual'] as num).toDouble(),
      precioOriginal: (json['precio_original'] as num).toDouble(),
    );
  }
}
