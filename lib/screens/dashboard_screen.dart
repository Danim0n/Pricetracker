import 'package:flutter/material.dart';
import 'package:pricetracker_app/models/product_model.dart';
import 'package:pricetracker_app/screens/product_detail_screen.dart';
import 'package:pricetracker_app/service/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double precioactual = 1800;
  double preciooriginal = 2400;

  @override
  void initState() {
    super.initState();
  }

  // 2. LA FUNCIÓN DE RECARGA: Va dentro del estado de tu Widget
  Future<void> _recargarDatos() async {
    setState(() {}); // Esto redibuja la pantalla con los datos nuevos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(radius: 20, child: Icon(Icons.person)),
            ),
            title: Text('Nombre'),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_none_outlined),
              ),
            ],
            shape: Border(bottom: BorderSide(width: 0.2, color: Colors.black)),
          ),
          body: RefreshIndicator(
            onRefresh: _recargarDatos,
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 20, right: 20, left: 20),
              child: Column(
                spacing: 25,
                children: [
                  Card(
                    elevation: 10,
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 15,
                          children: [
                            // datos inventados cambiarlos luego
                            Text('Value Watchlist value'),
                            Text('1400 \$'),
                            Text('-4.15% today'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text('Activate alterts'),
                                    Text('12'),
                                  ],
                                ),
                                VerticalDivider(
                                  width: 30,
                                  thickness: 1,
                                  indent: 50,
                                  endIndent: 0,
                                  color: Colors.black,
                                ),
                                Column(
                                  children: [
                                    Text('Activate alterts'),
                                    Text('12'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Product>>(
                      future: ApiService().fetchProductos(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error al cargar los productos ${snapshot.error}',
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              'No hay productos en seguimiento actualmente.',
                            ),
                          );
                        }

                        final productos = snapshot.data!;

                        return ListView.separated(
                          itemCount: productos.length,
                          separatorBuilder: (context, _) {
                            return SizedBox(height: 20);
                          },
                          itemBuilder: (context, i) {
                            return SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                                        producto: productos[i],
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 20,
                                      children: [
                                        Text(productos[i].nombre),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadiusGeometry.all(
                                                Radius.circular(10),
                                              ),
                                          child: Image.network(
                                            'https://cors-anywhere.herokuapp.com/${productos[i].imagenUrl}',
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  print(error);
                                                  return Center(
                                                    child: Icon(
                                                      Icons.image,
                                                      size: 100,
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                        Row(
                                          spacing: 8,
                                          children: [
                                            Icon(
                                              productos[i].precioActual <
                                                      preciooriginal
                                                  ? Icons.arrow_downward_rounded
                                                  : Icons.arrow_upward_rounded,
                                              color:
                                                  productos[i].precioActual <
                                                      preciooriginal
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            Text(
                                              'Precio Actual: ${productos[i].precioActual}\$  |  Precio Original: $preciooriginal}\$',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
