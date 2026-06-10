import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pricetracker_app/models/price_history_model.dart';
import 'package:pricetracker_app/models/product_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<Product>> fetchProductos() async {
    final response = await http.get(Uri.parse('$baseUrl/productos'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Error al conectar con la API de PriceTracker');
    }
  }

  Future<List<PriceHistory>> fetchHistorial(int productoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/productos/$productoId/historial'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => PriceHistory.fromJson(item)).toList();
    } else {
      throw Exception('No se pudo obtener el historial del producto');
    }
  }

  Future<bool> guardarAlerta(
    int productoId,
    String email,
    double precioObjetivo,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alertas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'producto_id': productoId,
        'email': email,
        'precio_objetivo': precioObjetivo,
      }),
    );

    return response.statusCode == 200;
  }
}
