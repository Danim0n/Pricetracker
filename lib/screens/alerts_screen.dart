import 'package:flutter/material.dart';
import 'package:pricetracker_app/service/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final ApiService _apiService = ApiService();

  List<dynamic> _alertas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final alertas = await _apiService.obtenerAlertas();
      setState(() {
        _alertas = alertas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mis Alertas',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error al cargar las alertas: $_error'));
    }
    if (_alertas.isEmpty) {
      return const Center(
        child: Text('No tienes alertas configuradas todavía.'),
      );
    }

    return ListView.separated(
      itemCount: _alertas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final alerta = _alertas[i];

        bool isSwitchedOn = alerta.activa == 1 || alerta.activa == true;

        return Card(
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.network(
                      '',
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_outlined, size: 100);
                      },
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Text(
                        alerta.product.nombre,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'Precio Actual / Precio Objetivo',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${alerta.product.precioActual}€',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${alerta.precioObjetivo}€',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(thickness: 0.4, color: Colors.black),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Switch(
                      value: isSwitchedOn,
                      activeThumbColor: Colors.orange,
                      onChanged: (bool nuevoValor) async {
                        // A) Cambiar estado local inmediatamente (UI fluida)
                        setState(() {
                          alerta.activa = nuevoValor;
                        });

                        // B) Enviar a la API
                        bool exito = await _apiService.actualizarEstadoAlerta(
                          alerta.id,
                          nuevoValor,
                        );

                        // C) Si falla, revertir
                        if (!exito) {
                          setState(() {
                            alerta.activa = !nuevoValor;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Error al sincronizar con el servidor',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirmación'),
                              content: const Text(
                                '¿Estás seguro de que quieres eliminar la alerta?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: const Text('Eliminar'),
                                  onPressed: () async {
                                    int alertaId = alerta.id;
                                    bool borrado = await _apiService
                                        .eliminarAlerta(alertaId);
                                    Navigator.of(context).pop();
                                    if (borrado) {
                                      // Recargar alertas desde la API
                                      _cargarAlertas();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Alerta eliminada correctamente.',
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'No se pudo eliminar la alerta.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.black54,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
