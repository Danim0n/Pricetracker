import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pricetracker_app/models/alerta_model.dart';
import 'package:pricetracker_app/models/price_history_model.dart';
import 'package:pricetracker_app/models/product_model.dart';

class ApiClient {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> getHeaders() async {
    String? token = await _storage.read(key: 'jwt');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/';
  final _cliente = ApiClient();

  // POST /products/track
  Future<bool> trackProducto(String urlProducto) async {
    final headers = await _cliente.getHeaders();
    final response = await http.post(
      Uri.parse('${baseUrl}products/track'),
      headers: headers,
      body: jsonEncode({'url': urlProducto}),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // GET /products
  Future<List<Product>> fetchProductos() async {
    final headers = await _cliente.getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}products'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    }
    throw Exception('Error al listar productos: ${response.statusCode}');
  }

  // GET /products/{id}
  Future<Product> fetchProductoDetalle(int productoId) async {
    final headers = await _cliente.getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}products/$productoId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al obtener detalle: ${response.statusCode}');
  }

  // PATCH /products/{id}
  Future<bool> actualizarProducto(int productoId, double precioObjetivo) async {
    final headers = await _cliente.getHeaders();
    final response = await http.patch(
      Uri.parse('${baseUrl}products/$productoId'),
      headers: headers,
      body: jsonEncode({'precio_objetivo': precioObjetivo}),
    );
    return response.statusCode == 200;
  }

  // DELETE /products/{id}
  Future<bool> borrarProducto(int productoId) async {
    final headers = await _cliente.getHeaders();
    final response = await http.delete(
      Uri.parse('${baseUrl}products/$productoId'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  // GET /products/{id}/history
  Future<List<PriceHistory>> fetchHistorial(int productoId) async {
    final headers = await _cliente.getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}products/$productoId/history'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => PriceHistory.fromJson(item)).toList();
    }
    throw Exception('Error al obtener historial: ${response.statusCode}');
  }

  // GET /alertas
  Future<List<Alerta>> obtenerAlertas() async {
    final headers = await _cliente.getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}alertas/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Alerta.fromJson(item)).toList();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  // 1. Guardar/Crear Alerta
  Future<bool> guardarAlerta(
    int productoId,
    double precioObjetivo,
    bool activa,
  ) async {
    final headers = await _cliente.getHeaders();
    final response = await http.post(
      Uri.parse('${baseUrl}alertas/'),
      headers: headers,
      body: jsonEncode({
        'producto_id': productoId,
        'precio_objetivo': precioObjetivo,
        'activa': activa,
      }),
    );
    return response.statusCode == 201; // El POST debería devolver 201 Created
  }

  // 2. Actualizar estado (Activar/Desactivar)
  Future<bool> actualizarEstadoAlerta(int alertaId, bool esActiva) async {
    final headers = await _cliente.getHeaders();
    final response = await http.patch(
      Uri.parse('${baseUrl}alertas/$alertaId'),
      headers: headers,
      body: jsonEncode({"activa": esActiva}),
    );
    return response.statusCode == 200;
  }

  // 3. Eliminar Alerta
  Future<bool> eliminarAlerta(int alertaId) async {
    final headers = await _cliente.getHeaders();
    final response = await http.delete(
      Uri.parse('${baseUrl}alertas/$alertaId'),
      headers: headers,
    );
    return response.statusCode == 204;
  }
}
