class PriceHistory {
  final double precio;
  final DateTime fechaRegistro;

  PriceHistory({required this.precio, required this.fechaRegistro});

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      precio: (json['precio'] as num).toDouble(),
      fechaRegistro: DateTime.parse(json['fecha_registro']),
    );
  }
}
