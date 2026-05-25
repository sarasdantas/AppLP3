import 'package:flutter/material.dart';

class AvaliarColaboradorPage extends StatefulWidget {
  const AvaliarColaboradorPage({super.key});

  @override
  State<AvaliarColaboradorPage> createState() => _AvaliarColaboradorPageState();
}

class _AvaliarColaboradorPageState extends State<AvaliarColaboradorPage> {
  int _notaEstrelas = 0;
  final _comentarioController = TextEditingController();

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar Colaborador'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Como foi a faxina com Maria Silva?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Sua avaliação ajuda a manter a qualidade da comunidade.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Linha de Seleção de Estrelas (Interativa)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _notaEstrelas ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _notaEstrelas = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 32),

            // Campo de comentário por texto
            TextField(
              controller: _comentarioController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Deixe um comentário sobre o serviço (opcional)...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),

            // Botão de envio
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _notaEstrelas == 0
                    ? null // Desabilita o botão se não selecionou nenhuma estrela
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Obrigado pela sua avaliação!'),
                          ),
                        );
                        // Limpa o histórico de navegação e volta para a dashboard do cliente
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/cliente/dashboard',
                          (route) => false,
                        );
                      },
                child: const Text(
                  'Enviar Avaliação',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
