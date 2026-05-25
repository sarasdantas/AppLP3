import 'package:flutter/material.dart';

class ClienteDashboardPage extends StatelessWidget {
  const ClienteDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minhas Faxinas'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Agendados'),
              Tab(text: 'Em Andamento'),
              Tab(text: 'Concluídos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Aba 1: Agendados
            _buildListaServicos(
              context,
              status: 'Agendado',
              icone: Icons.calendar_today,
              corIcone: Colors.blue,
            ),
            // Aba 2: Em Andamento
            _buildListaServicos(
              context,
              status: 'Em Andamento',
              icone: Icons.autorenew,
              corIcone: Colors.orange,
            ),
            // Aba 3: Concluídos
            _buildListaServicos(
              context,
              status: 'Concluído',
              icone: Icons.check_circle,
              corIcone: Colors.green,
            ),
          ],
        ),
        // Botão flutuante para criar um novo serviço
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/cliente/criar-servico');
          },
          label: const Text('Pedir Faxina'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildListaServicos(
    BuildContext context, {
    required String status,
    required IconData icone,
    required Color corIcone,
  }) {
    // Exemplo de dados mockados (simulados)
    final listagemSimulada = [
      {
        'data': '28/05/2026',
        'tipo': 'Faxina Padrão',
        'endereco': 'Av. Paulista, 1000 - Ap 42',
        'colaborador': status == 'Agendado' ? 'Aguardando...' : 'Maria Silva',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listagemSimulada.length,
      itemBuilder: (context, index) {
        final servico = listagemSimulada[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: corIcone.withOpacity(0.1),
              child: Icon(icone, color: corIcone),
            ),
            title: Text(
              servico['tipo']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Data: ${servico['data']}'),
                Text('Endereço: ${servico['endereco']}'),
                Text('Profissional: ${servico['colaborador']}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navega para os detalhes enviando o status atual como argumento
              Navigator.pushNamed(
                context,
                '/cliente/detalhes-servico',
                arguments: status,
              );
            },
          ),
        );
      },
    );
  }
}
