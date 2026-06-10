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
    bool activa,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/alertas');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'producto_id': productoId,
          'email': email,
          'precio_objetivo': precioObjetivo,
          'activa': activa, // Pasamos el booleano al backend
        }),
      );

      if (response.statusCode == 200) {
        final resultado = jsonDecode(response.body);
        return resultado['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error en guardarAlerta: $e');
      return false;
    }
  }

  Future<List<dynamic>> obtenerAlertas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/alertas'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cargar alertas del servidor');
      }
    } catch (e) {
      throw Exception('No se pudo conectar con el backend: $e');
    }
  }

  Future<Map<String, dynamic>> obtenerAlertaUsuario(
    int productoId,
    String email,
  ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/productos/$productoId/alerta-usuario?email=$email',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener el estado de la alerta');
      }
    } catch (e) {
      throw Exception('Error de conexión al consultar alerta: $e');
    }
  }
}
