import 'package:flutter/material.dart';
import 'splash.dart';
import 'login.dart';
import 'lista.dart';
import 'cliente_detalhes_servico.dart';
import 'colaborador_execucao_servico.dart';
import 'editar_faxina.dart';
import 'analisar_perfil.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casa Limpa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF4F46E5),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/lista': (context) => const ListaPage(),
        '/cliente/detalhes': (context) => const ClienteDetalhesServicoPage(),
        '/colaborador/detalhes': (context) => const ColaboradorExecucaoServicoPage(),
        '/perfil': (context) => const AnalisarPerfilPage(),
        '/editar': (context) => const EditarFaxinaPage(),
      },
    );
  }
}
