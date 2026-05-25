import 'package:flutter/material.dart';

class _Tarefa {
  final String nome;
  final bool concluida;
  const _Tarefa(this.nome, this.concluida);
}

class ClienteDetalhesServicoPage extends StatelessWidget {
  const ClienteDetalhesServicoPage({super.key});

  static const _tarefas = <_Tarefa>[
    _Tarefa('Limpeza dos quartos', true),
    _Tarefa('Limpeza dos banheiros', true),
    _Tarefa('Aspirar e passar pano na sala', false),
    _Tarefa('Limpeza da cozinha', false),
  ];

  static const _servico = {
    'colaborador': 'Maria Silva',
    'endereco': 'Av. Principal, 456 - Centro',
    'data': '29/04/2026',
    'valor': 200,
  };

  @override
  Widget build(BuildContext context) {
    final status = ModalRoute.of(context)?.settings.arguments as String? ??
        'Em Andamento';
    final concluidas = _tarefas.where((t) => t.concluida).length;
    final progresso = _tarefas.isEmpty ? 0.0 : concluidas / _tarefas.length;
    final progressoPct = (progresso * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          'Detalhes do Serviço',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardColaborador(status),
            const SizedBox(height: 12),
            _buildCardInfo(),
            const SizedBox(height: 12),
            _buildCardProgresso(progresso, progressoPct, concluidas),
            const SizedBox(height: 12),
            _buildChecklist(),
            const SizedBox(height: 20),
            if (status == 'Concluído')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/cliente/avaliar',
                    arguments: _servico['colaborador'],
                  ),
                  icon: const Icon(Icons.star),
                  label: const Text(
                    'Avaliar Serviço',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFACC15),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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

  Widget _buildCardColaborador(String status) {
    return _cardBase(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFEDE9FE),
            child: Text(
              (_servico['colaborador'] as String).characters.first,
              style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _servico['colaborador'] as String,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Colaboradora',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                _badgeStatus(status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfo() {
    return _cardBase(
      child: Column(
        children: [
          _linhaInfo(Icons.location_on_outlined, 'Endereço',
              _servico['endereco'] as String),
          const SizedBox(height: 14),
          _linhaInfo(Icons.calendar_today_outlined, 'Data',
              _servico['data'] as String),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Valor do serviço',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                'R\$ ${_servico['valor']}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _linhaInfo(IconData icone, String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: const Color(0xFF2563EB), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(valor,
                  style: TextStyle(
                      color: Colors.grey.shade700, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardProgresso(double progresso, int pct, int concluidas) {
    return _cardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progresso da limpeza',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$concluidas de ${_tarefas.length} tarefas concluídas',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    return _cardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Lista de tarefas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          for (int i = 0; i < _tarefas.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _tarefas[i].concluida
                          ? const Color(0xFF16A34A)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _tarefas[i].concluida
                            ? const Color(0xFF16A34A)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: _tarefas[i].concluida
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _tarefas[i].nome,
                      style: TextStyle(
                        fontSize: 14,
                        color: _tarefas[i].concluida
                            ? Colors.grey.shade400
                            : Colors.black87,
                        decoration: _tarefas[i].concluida
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: _tarefas[i].concluida
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < _tarefas.length - 1)
              Divider(height: 1, color: Colors.grey.shade100),
          ],
        ],
      ),
    );
  }

  Widget _badgeStatus(String status) {
    final (corFundo, corTexto) = switch (status) {
      'Agendado' => (const Color(0xFFFEF3C7), const Color(0xFFA16207)),
      'Concluído' => (const Color(0xFFDCFCE7), const Color(0xFF15803D)),
      _ => (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: corTexto,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
