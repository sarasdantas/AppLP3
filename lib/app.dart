import 'package:casa_limpa/lista.dart';
import 'package:casa_limpa/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'avaliar_colaborador.dart';
import 'cliente_dashboard.dart';
import 'cliente_detalhes_servico.dart';
import 'colaborador_execucao_servico.dart';
import 'colaborador_feed_oportunidades.dart';
import 'criar_servico.dart';
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
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => LoginPage(),
        '/registro': (context) => RegistroPage(),
        '/lista': (context) => ListaPage(),
        '/cliente/dashboard': (context) => const ClienteDashboardPage(),
        '/cliente/criar-servico': (context) => const CriarServicoPage(),
        '/cliente/detalhes-servico': (context) =>
            const ClienteDetalhesServicoPage(),
        '/cliente/avaliar': (context) => const AvaliarColaboradorPage(),
        '/colaborador/feed': (context) =>
            const ColaboradorFeedOportunidadesPage(),
        '/colaborador/execucao-servico': (context) =>
            const ColaboradorExecucaoServicoPage(),
      },
      initialRoute: '/',
    );
  }
}
