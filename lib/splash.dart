import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              children: [
                // ── Espaço superior ──────────────────────────────────────
                const Spacer(),

                // ── Ícone ────────────────────────────────────────────────
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 64,
                ),

                const SizedBox(height: 20),

                // ── Título ───────────────────────────────────────────────
                const Text(
                  'Casa Limpa',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Subtítulo ────────────────────────────────────────────
                const Text(
                  'Conectando você aos melhores\nserviços de limpeza',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                // ── Botão Cliente ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    // Botão Cliente
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/login',
                      arguments: 'cliente',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6366F1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Sou Cliente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Botão Colaboradora ───────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/login',
                      arguments: 'colaboradora',
                    ),
                    icon: const Icon(Icons.person_outline_rounded, size: 20),
                    label: const Text(
                      'Sou Colaboradora',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Rodapé ───────────────────────────────────────────────
                const Text(
                  'Projeto Acadêmico - Casa Limpa © 2026',
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
