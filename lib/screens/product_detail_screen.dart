import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  bool switchActivado = false;
  TextEditingController precioController = TextEditingController();
  bool alertaActivada = false;
  @override
  void dispose() {
    precioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargarAlertaExistente();
  }

  void _cargarAlertaExistente() async {
    final apiService = ApiService();
    try {
      // Llamas a tu ApiService apuntando al nuevo endpoint GET /productos/{id}/alerta-usuario
      final datosAlerta = await apiService.obtenerAlertaUsuario(
        widget.producto.id,
        "danirosellmartin@gmail.com",
      );

      if (datosAlerta['existe'] == true) {
        setState(() {
          precioController.text = datosAlerta['precio_objetivo'];
          alertaActivada = datosAlerta['activa'];
        });
      }
    } catch (e) {
      throw Exception("No había alerta previa o falló la conexión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
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
                  future: apiService.fetchHistorial(widget.producto.id),
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
                      // 1. Si intenta activar sin precio, lo frenamos
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

                      // 2. Cambiamos el estado visual del Switch
                      setState(() {
                        switchActivado = !switchActivado;
                      });

                      // 3. Si se ha activado, disparamos la petición a la API
                      if (switchActivado) {
                        double? precioDestino = double.tryParse(
                          precioController.text,
                        );
                        if (precioDestino != null) {
                          bool ok = await apiService.guardarAlerta(
                            widget.producto.id,
                            "danirosellmartin@gmail.com",
                            precioDestino,
                            alertaActivada,
                          );
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Alerta guardada!'),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
