import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pricetracker_app/models/product_model.dart';
import 'package:pricetracker_app/screens/product_detail_screen.dart';
import 'package:pricetracker_app/service/api_service.dart';
import 'package:pricetracker_app/service/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _datosFuture;
  final _storage = const FlutterSecureStorage();
  String _nombreUsuario = 'Cargando';

  @override
  void initState() {
    super.initState();
    _datosFuture = _fetchDatos();
  }

  Future<List<dynamic>> _fetchDatos() {
    return Future.wait([
      _apiService.obtenerResumen(),
      _apiService.fetchProductos(),
      _apiService.obtenerAlertas(),
    ]);
  }

  Future<void> _cargarNombre() async {
    String? nombre = await _storage.read(key: 'nombre');

    if (nombre != null && nombre.isNotEmpty) {
      setState(() {
        _nombreUsuario = nombre;
      });
    } else {
      setState(() {
        _nombreUsuario = "Usuario";
      });
    }
  }

  Future<void> _recargarDatos() async {
    setState(() {
      _datosFuture = _fetchDatos();
    });
  }

  Map<String, dynamic>? _buscarAlertaDeProducto(
    List<dynamic> alertas,
    int productoId,
  ) {
    try {
      return alertas.firstWhere((a) => a['producto_id'] == productoId)
          as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarNombre();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(radius: 20, child: Icon(Icons.person)),
        ),
        title: Text(_nombreUsuario),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(width: 0.2, color: Colors.black),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _recargarDatos,
        child: FutureBuilder<List<dynamic>>(
          future: _datosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar la información: ${snapshot.error}',
                ),
              );
            }

            final resumen = snapshot.data![0] as Map<String, dynamic>;
            final productos = snapshot.data![1] as List<Product>;
            final alertas = snapshot.data![2] as List<dynamic>;
            double varPorcentaje = resumen['porcentaje_variacion'] ?? 0.0;
            bool esBajada = varPorcentaje < 0;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  sliver: SliverToBoxAdapter(
                    child: Card(
                      elevation: 10,
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Valor total del seguimiento',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${resumen['total_watchlist_value']}€',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    esBajada
                                        ? Icons.trending_down_rounded
                                        : Icons.trending_up_rounded,
                                    color: esBajada
                                        ? const Color(0xFFFF8A65)
                                        : Colors.greenAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${varPorcentaje.abs()}% Today',
                                    style: TextStyle(
                                      color: esBajada
                                          ? const Color(0xFFFF8A65)
                                          : Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'vs. original price',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(40),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(thickness: 0.5, color: Colors.grey),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        'Alertas Activas',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${resumen['alertas_activas']}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 40,
                                    child: VerticalDivider(
                                      thickness: 1,
                                      color: Colors.black26,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        'Total Alertas',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${resumen['total_alertas']}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 25)),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  sliver: productos.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Text(
                              'No hay productos en seguimiento actualmente.',
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((context, i) {
                            final producto = productos[i];
                            final alerta = _buscarAlertaDeProducto(
                              alertas,
                              producto.id,
                            );
                            final precioObjetivo = alerta != null
                                ? '${alerta['precio_objetivo']}€'
                                : 'Sin alerta';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Eliminar producto'),
                                        content: Text(
                                          '¿Estás seguro de que deseas eliminar este producto?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              final eliminar =
                                                  await ApiService()
                                                      .borrarProducto(
                                                        producto.id,
                                                      );
                                              if (eliminar) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Producto eliminado correctamente',
                                                    ),
                                                  ),
                                                );
                                                _recargarDatos();
                                              }
                                            },
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailScreen(
                                              producto: producto,
                                            ),
                                      ),
                                    ).then((_) => _recargarDatos());
                                  },
                                  child: Card(
                                    elevation: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            producto.nombre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.network(
                                              producto.imagenUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return const Center(
                                                      child: Icon(
                                                        Icons.image,
                                                        size: 100,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              Icon(
                                                producto.precioActual <
                                                        producto.precioOriginal
                                                    ? Icons
                                                          .arrow_downward_rounded
                                                    : producto.precioActual ==
                                                          producto
                                                              .precioOriginal
                                                    ? Icons.drag_handle_outlined
                                                    : Icons
                                                          .arrow_upward_rounded,
                                                color:
                                                    producto.precioActual <
                                                        producto.precioOriginal
                                                    ? Colors.green
                                                    : producto.precioActual ==
                                                          producto
                                                              .precioOriginal
                                                    ? Colors.amber
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (producto.precioActual <
                                                        producto.precioOriginal)
                                                      Text(
                                                        'Precio Original: ${producto.precioOriginal}€',
                                                        style: const TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                      ),
                                                    Row(
                                                      spacing: 20,
                                                      children: [
                                                        Text(
                                                          'Precio Actual: ${producto.precioActual}€',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                producto.precioActual <
                                                                    producto
                                                                        .precioOriginal
                                                                ? FontWeight
                                                                      .bold
                                                                : FontWeight
                                                                      .w500,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Precio deseado: $precioObjetivo',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }, childCount: productos.length),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
