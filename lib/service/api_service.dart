import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
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

  Future<List<Product>> fetchProductos() async {
    final headers = await _cliente.getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}productos'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> obtenerResumen() async {
    final headers = await _cliente.getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}resumen'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error: ${response.statusCode}');
  }

  Future<List<PriceHistory>> fetchHistorial(int productoId) async {
    final headers = await _cliente.getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}productos/$productoId/historial'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => PriceHistory.fromJson(item)).toList();
    }
    throw Exception('Error: ${response.statusCode}');
  }

  Future<List<dynamic>> obtenerAlertas() async {
    final headers = await _cliente.getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}alertas'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error: ${response.statusCode}');
  }

  Future<bool> agregarProductoUrl(String urlProducto) async {
    final headers = await _cliente.getHeaders();
    final response = await http.post(
      Uri.parse('${baseUrl}productos'),
      headers: headers,
      body: jsonEncode({'url': urlProducto}),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> borrarProducto(int productoId) async {
    final headers = await _cliente.getHeaders();
    final response = await http.delete(
      Uri.parse('${baseUrl}productos/$productoId'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> obtenerAlertaUsuario(
    int productoId,
    String email,
  ) async {
    final headers = await _cliente.getHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}productos/$productoId/alerta-usuario?email=$email'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error: ${response.statusCode}');
  }

  Future<bool> guardarAlerta(
    int productoId,
    String email,
    double precioObjetivo,
    bool activa,
  ) async {
    final headers = await _cliente.getHeaders();
    final response = await http.post(
      Uri.parse('${baseUrl}alertas'),
      headers: headers,
      body: jsonEncode({
        'producto_id': productoId,
        'email': email,
        'precio_objetivo': precioObjetivo,
        'activa': activa,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> actualizarEstadoAlerta(int alertaId, bool esActiva) async {
    final headers = await _cliente.getHeaders();
    final response = await http.put(
      Uri.parse('${baseUrl}alertas/$alertaId/status'),
      headers: headers,
      body: jsonEncode({"activa": esActiva}),
    );
    return response.statusCode == 200;
  }

  Future<bool> eliminarAlerta(int alertaId) async {
    final headers = await _cliente.getHeaders();
    final response = await http.delete(
      Uri.parse('${baseUrl}alertas/$alertaId'),
      headers: headers,
    );
    return response.statusCode == 200;
  }
}
