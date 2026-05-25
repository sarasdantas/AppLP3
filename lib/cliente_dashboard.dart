import 'package:flutter/material.dart';

enum _StatusServico { aberto, emAndamento, finalizado }

class _Servico {
  final String id;
  final String data;
  final String endereco;
  final int valor;
  final _StatusServico status;
  final int tarefas;
  final String? colaborador;

  const _Servico({
    required this.id,
    required this.data,
    required this.endereco,
    required this.valor,
    required this.status,
    required this.tarefas,
    this.colaborador,
  });
}

enum _Aba { todos, abertos, finalizados }

class ClienteDashboardPage extends StatefulWidget {
  const ClienteDashboardPage({super.key});

  @override
  State<ClienteDashboardPage> createState() => _ClienteDashboardPageState();
}

class _ClienteDashboardPageState extends State<ClienteDashboardPage> {
  _Aba _aba = _Aba.todos;

  static const _servicos = <_Servico>[
    _Servico(
      id: '1',
      data: '05/05/2026',
      endereco: 'Rua das Flores, 123',
      valor: 150,
      status: _StatusServico.aberto,
      tarefas: 5,
    ),
    _Servico(
      id: '2',
      data: '29/04/2026',
      endereco: 'Av. Principal, 456',
      valor: 200,
      status: _StatusServico.emAndamento,
      tarefas: 8,
      colaborador: 'Maria Silva',
    ),
    _Servico(
      id: '3',
      data: '20/04/2026',
      endereco: 'Rua do Comércio, 789',
      valor: 180,
      status: _StatusServico.finalizado,
      tarefas: 6,
      colaborador: 'Ana Santos',
    ),
  ];

  List<_Servico> get _filtrados {
    switch (_aba) {
      case _Aba.abertos:
        return _servicos
            .where((s) =>
                s.status == _StatusServico.aberto ||
                s.status == _StatusServico.emAndamento)
            .toList();
      case _Aba.finalizados:
        return _servicos
            .where((s) => s.status == _StatusServico.finalizado)
            .toList();
      case _Aba.todos:
        return _servicos;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildAbas(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _filtrados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _buildCardServico(_filtrados[i]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/cliente/criar-servico'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá! 👋',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Gerencie suas faxinas',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildAbas() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          _pillAba('Todos', _Aba.todos),
          const SizedBox(width: 8),
          _pillAba('Abertos', _Aba.abertos),
          const SizedBox(width: 8),
          _pillAba('Finalizados', _Aba.finalizados),
        ],
      ),
    );
  }

  Widget _pillAba(String label, _Aba aba) {
    final selecionado = _aba == aba;
    return GestureDetector(
      onTap: () => setState(() => _aba = aba),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selecionado
              ? const Color(0xFF2563EB)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selecionado ? Colors.white : Colors.grey.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCardServico(_Servico s) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.pushNamed(
        context,
        '/cliente/detalhes-servico',
        arguments: _statusLabel(s.status),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.endereco,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.data,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _badgeStatus(s.status),
              ],
            ),
            if (s.colaborador != null) ...[
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: 'Colaborador: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  children: [
                    TextSpan(
                      text: s.colaborador,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${s.tarefas} tarefas',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'R\$ ${s.valor}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            if (s.status == _StatusServico.finalizado) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/cliente/avaliar',
                    arguments: s.colaborador,
                  ),
                  icon: const Icon(Icons.star, size: 18),
                  label: const Text('Avaliar serviço'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFACC15),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badgeStatus(_StatusServico status) {
    final (corFundo, corTexto, icone, label) = switch (status) {
      _StatusServico.aberto => (
          const Color(0xFFFEF3C7),
          const Color(0xFFA16207),
          Icons.schedule,
          'Aberto',
        ),
      _StatusServico.emAndamento => (
          const Color(0xFFDBEAFE),
          const Color(0xFF1D4ED8),
          Icons.autorenew,
          'Em andamento',
        ),
      _StatusServico.finalizado => (
          const Color(0xFFDCFCE7),
          const Color(0xFF15803D),
          Icons.check_circle,
          'Finalizado',
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: corTexto),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: corTexto,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(_StatusServico s) => switch (s) {
        _StatusServico.aberto => 'Agendado',
        _StatusServico.emAndamento => 'Em Andamento',
        _StatusServico.finalizado => 'Concluído',
      };
}
