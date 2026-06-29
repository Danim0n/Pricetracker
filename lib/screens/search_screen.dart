import 'package:flutter/material.dart';
import 'package:pricetracker_app/service/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool cargando = false;
  final ApiService _apiService = ApiService();
  Future buscarProducto() async {
    final urltrim = _urlController.text.trim();
    if (urltrim.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una url para comenzar a buscar')),
      );
      return;
    }

    if (!urltrim.startsWith('http://') && !urltrim.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa una url valida para comenzar a buscar'),
        ),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final guardado = await _apiService.trackProducto(urltrim);

      if (!mounted) return;

      if (guardado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto agregado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _urlController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La tienda no es compatible o el producto no se pudo encontrar.',
            ),
          ),
        );
      }
      _urlController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar el producto $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastrear Producto'),
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pega el enlace del producto'),
            SizedBox(
              height: 60,
              child: TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.link),
                  suffixIcon: _urlController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => _urlController.clear(),
                        )
                      : null,
                  hintText: 'https://ejemplo/producto.com',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (texto) => setState(() {}),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: Colors.amberAccent,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.amberAccent[100]!, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: cargando ? null : buscarProducto,
                child: cargando
                    ? const Center(child: CircularProgressIndicator())
                    : const Text(
                        'Buscar',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
