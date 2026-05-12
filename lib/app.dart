import 'package:casa_limpa/lista.dart';
import 'package:casa_limpa/splash.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'registro.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casa Limpa',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B82F6),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => LoginPage(),
        '/registro': (context) => RegistroPage(),
        '/lista': (context) => ListaPage(),
      },
      initialRoute: '/',
    );
  }
}
