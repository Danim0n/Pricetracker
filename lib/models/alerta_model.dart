import 'package:pricetracker_app/models/product_model.dart';

class Alerta {
  final int id;
  final int usuarioId;
  final int productoId;
  double precioObjetivo;
  bool activa;
  bool notificada;
  final String? ultimoCanal;
  final DateTime? ultimaNotificacionEn;
  final DateTime creadoEn;
  final Product product;

  Alerta({
    required this.id,
    required this.usuarioId,
    required this.productoId,
    required this.precioObjetivo,
    required this.activa,
    required this.notificada,
    this.ultimoCanal,
    this.ultimaNotificacionEn,
    required this.creadoEn,
    required this.product,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      id: json['id'],
      usuarioId: json['usuario_id'],
      productoId: json['producto_id'],
      precioObjetivo: double.parse(json['precio_objetivo'].toString()),
      activa: json['activa'],
      notificada: json['notificada'],
      ultimoCanal: json['ultimo_canal'],
      ultimaNotificacionEn: json['ultima_notificacion_en'] != null
          ? DateTime.parse(json['ultima_notificacion_en'])
          : null,
      creadoEn: DateTime.parse(json['creado_en']),
      product: Product.fromJson(json['producto'] as Map<String, dynamic>),
    );
  }
}
