import 'package:flutter/material.dart';

class AvaliarColaboradorPage extends StatefulWidget {
  const AvaliarColaboradorPage({super.key});

  @override
  State<AvaliarColaboradorPage> createState() => _AvaliarColaboradorPageState();
}

class _AvaliarColaboradorPageState extends State<AvaliarColaboradorPage> {
  int _nota = 0;
  final _comentarioController = TextEditingController();

  static const _legendas = {
    0: 'Selecione uma nota',
    1: 'Muito ruim',
    2: 'Ruim',
    3: 'Regular',
    4: 'Bom',
    5: 'Excelente!',
  };

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _enviar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Obrigado pela sua avaliação!')),
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/cliente/dashboard',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colaborador =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Maria Silva';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          'Avaliar Serviço',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _cardColaborador(colaborador),
            const SizedBox(height: 12),
            _cardEstrelas(),
            const SizedBox(height: 12),
            _cardComentario(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nota == 0 ? null : _enviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Enviar Avaliação',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardBase({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _cardColaborador(String nome) {
    return _cardBase(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE9FE),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              nome.characters.first,
              style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nome,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Colaboradora',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _cardEstrelas() {
    return _cardBase(
      child: Column(
        children: [
          const Text(
            'Como foi o serviço?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final preenchida = i < _nota;
              return GestureDetector(
                onTap: () => setState(() => _nota = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedScale(
                    scale: preenchida ? 1.0 : 0.95,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      preenchida ? Icons.star : Icons.star_border,
                      color: preenchida
                          ? const Color(0xFFFACC15)
                          : Colors.grey.shade300,
                      size: 44,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _legendas[_nota] ?? '',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _cardComentario() {
    return _cardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deixe um comentário (opcional)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _comentarioController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Conte como foi sua experiência...',
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF5F6F8),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
