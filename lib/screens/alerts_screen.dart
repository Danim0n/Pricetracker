import 'package:flutter/material.dart';

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
                child: ListView.separated(
                  separatorBuilder: (context, _) {
                    return SizedBox(height: 20);
                  },
                  itemCount: 3,
                  itemBuilder: (context, _) {
                    return Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          spacing: 20,
                          children: [
                            Text('nombre del producto'),
                            Table(
                              children: [
                                TableRow(
                                  children: [
                                    Text('Precio actual'),
                                    Text('Precio objetivo'),
                                  ],
                                ),
                                TableRow(
                                  children: [Text('2400\$'), Text('1400\$')],
                                ),
                              ],
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 35,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () {},
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red[100],
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
