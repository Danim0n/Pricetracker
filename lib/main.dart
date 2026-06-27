import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pricetracker_app/screens/home_screen.dart';
import 'package:pricetracker_app/screens/main_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      home: AuthWrapper(),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class AuthWrapper extends StatelessWidget {
  final _storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _storage.read(key: 'jwt'), // Comprobamos si hay token
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si hay token, al Dashboard. Si no, al Login.
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
