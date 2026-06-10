import 'package:flutter/material.dart';
import 'package:pricetracker_app/service/api_service.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 20,
            children: [
              Text(
                'Mis Alertas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder(
                  future: ApiService().obtenerAlertas(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No tienes ninguna alerta creada todavía.'),
                      );
                    }

                    final alertas = snapshot.data!;
                    return ListView.separated(
                      separatorBuilder: (context, _) {
                        return SizedBox(height: 20);
                      },
                      itemCount: alertas.length,
                      itemBuilder: (context, i) {
                        final alerta = alertas[i];
                        return Card(
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 20,
                              children: [
                                Row(
                                  spacing: 50,
                                  children: [
                                    Image.network(
                                      'https://cors-anywhere.herokuapp.com/${alerta['producto_imagen']}',
                                      fit: BoxFit.cover,
                                      height: 100,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.image_outlined,
                                              size: 100,
                                            );
                                          },
                                    ),
                                    Flexible(
                                      child: Text(
                                        alerta['producto_nombre'],
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Text('Precio Actual / Precio Objetivo'),

                                SizedBox(
                                  width: 150,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        alerta['producto_precio_actual']
                                            .toString(),
                                      ),
                                      Text(
                                        alerta['precio_objetivo'].toString(),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(thickness: 0.4, color: Colors.black),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  spacing: 100,
                                  children: [
                                    Switch(value: true, onChanged: (e) {}),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
