import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pricetracker_app/models/alerta_model.dart';
import 'package:pricetracker_app/models/price_history_model.dart';
import 'package:pricetracker_app/models/product_model.dart';
import 'package:pricetracker_app/service/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product producto;
  const ProductDetailScreen({super.key, required this.producto});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();
  TextEditingController precioController = TextEditingController();

  bool switchActivado = false;
  bool cargandoAlerta = true;
  Alerta? alerta;

  @override
  void dispose() {
    precioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargarEstadoAlerta();
  }

  Future<void> _cargarEstadoAlerta() async {
    setState(() => cargandoAlerta = true);
    try {
      final alertas = await _apiService.obtenerAlertas();
      final alertaEncontrada = alertas
          .where((a) => a.productoId == widget.producto.id)
          .firstOrNull;

      setState(() {
        alerta = alertaEncontrada;
        if (alerta != null) {
          switchActivado = alerta!.activa;
          precioController.text = alerta!.precioObjetivo.toString();
        }
        cargandoAlerta = false;
      });
    } catch (e) {
      setState(() => cargandoAlerta = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 20,
            children: [
              SizedBox(
                child: Text(
                  widget.producto.nombre,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Text('Precio actual: ${widget.producto.precioActual}'),

              SizedBox(
                height: 400,
                width: double.infinity,
                child: FutureBuilder<List<PriceHistory>>(
                  future: _apiService.fetchHistorial(widget.producto.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Sin datos históricos suficientes.'),
                      );
                    }

                    final historial = snapshot.data!;

                    List<FlSpot> spots = [];
                    for (int i = 0; i < historial.length; i++) {
                      spots.add(FlSpot(i.toDouble(), historial[i].precio));
                    }

                    if (spots.isEmpty) {
                      spots = [
                        const FlSpot(0, 100),
                        const FlSpot(1, 120),
                        const FlSpot(2, 90),
                      ];
                    }

                    return LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: historial.length > 1
                            ? (historial.length - 1).toDouble()
                            : 1.0,

                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.round();

                                if (index >= 0 && index < historial.length) {
                                  final DateTime fecha =
                                      historial[index].fechaRegistro;

                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 8.0,
                                    child: Text(
                                      '${fecha.day}/${fecha.month}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            dotData: FlDotData(show: false),
                            isCurved: false,
                            barWidth: 2,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      const Text(
                        'Avisarme si el precio esta por debajo de',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        width: 90,
                        height: 45,
                        child: TextField(
                          controller: precioController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            suffixText: '€',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: switchActivado,
                    activeThumbColor: Colors.blue,
                    onChanged: (bool nuevoValor) async {
                      if (nuevoValor && precioController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Introduce un precio objetivo primero',
                            ),
                          ),
                        );
                        return;
                      }

                      if (alerta != null) {
                        // ACTUALIZAR ALERTA
                        setState(() => switchActivado = nuevoValor);
                        bool exito = await _apiService.actualizarEstadoAlerta(
                          alerta!.id,
                          nuevoValor,
                        );
                        if (!exito) {
                          setState(
                            () => switchActivado = !nuevoValor,
                          ); // Revertir
                        }
                      } else {
                        // CREAR ALERTA
                        double? precioDestino = double.tryParse(
                          precioController.text,
                        );
                        if (precioDestino != null) {
                          bool ok = await _apiService.guardarAlerta(
                            widget.producto.id,
                            alerta!.precioObjetivo,
                            true,
                          );
                          if (ok) {
                            _cargarEstadoAlerta();
                          }
                        }
                      }
                    },
                  ),
                ],
              ),

              // Botón para eliminar la alerta
              if (alerta != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
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
                                  bool borrado = await _apiService
                                      .eliminarAlerta(alerta!.id);
                                  Navigator.of(context).pop();
                                  if (borrado) {
                                    setState(() {
                                      switchActivado = false;
                                      precioController.clear();
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Alerta eliminada correctamente.',
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Eliminar alerta',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
