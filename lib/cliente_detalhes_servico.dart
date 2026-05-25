import 'package:flutter/material.dart';

class ClienteDetalhesServicoPage extends StatefulWidget {
  const ClienteDetalhesServicoPage({super.key});

  @override
  State<ClienteDetalhesServicoPage> createState() => _ClienteDetalhesServicoPageState();
}

class _ClienteDetalhesServicoPageState extends State<ClienteDetalhesServicoPage> {
  // Checklist simulando o progresso da profissional
  final List<Map<String, dynamic>> _tarefasProgresso = [
    {'tarefa': 'Limpeza dos quartos', 'concluido': true},
    {'tarefa': 'Limpeza dos banheiros', 'concluido': true},
    {'tarefa': 'Aspirar e passar pano na sala', 'concluido': false},
    {'tarefa': 'Limpeza da cozinha', 'concluido': false},
  ];

  @override
  Widget build(BuildContext context) {
    // Recebe o status vindo da tela anterior (ou assume 'Em Andamento' por padrão)
    final String status = ModalRoute.of(context)?.settings.arguments as String? ?? 'Em Andamento';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Serviço'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bloco do Status e Informações da Profissional
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person, size: 35),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profissional: Maria Silva',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text('Status do Serviço: $status', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Título do Checklist
            const Text(
              'Progresso da Limpeza',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Lista de tarefas travada para o cliente (apenas leitura do progresso)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tarefasProgresso.length,
              itemBuilder: (context, index) {
                final item = _tarefasProgresso[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    item['concluido'] ? Icons.check_box : Icons.check_box_outline_blank,
                    color: item['concluido'] ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    item['tarefa'],
                    style: TextStyle(
                      decoration: item['concluido'] ? TextDecoration.lineThrough : null,
                      color: item['concluido'] ? Colors.grey : Colors.black,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Botão condicional: Se estiver concluído, exibe botão para avaliar
            if (status == 'Concluído')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cliente/avaliar');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text('Avaliar Serviço', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}