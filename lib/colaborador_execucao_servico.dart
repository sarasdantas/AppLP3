import 'package:flutter/material.dart';

class _Tarefa {
  final int id;
  final String nome;
  bool concluida;

  _Tarefa({required this.id, required this.nome, this.concluida = false});
}

class ColaboradorExecucaoServicoPage extends StatefulWidget {
  const ColaboradorExecucaoServicoPage({super.key});

  @override
  State<ColaboradorExecucaoServicoPage> createState() =>
      _ColaboradorExecucaoServicoPageState();
}

class _ColaboradorExecucaoServicoPageState
    extends State<ColaboradorExecucaoServicoPage> {
  final List<_Tarefa> _tarefas = [
    _Tarefa(id: 1, nome: 'Limpar banheiro', concluida: true),
    _Tarefa(id: 2, nome: 'Lavar louça', concluida: true),
    _Tarefa(id: 3, nome: 'Aspirar casa'),
    _Tarefa(id: 4, nome: 'Passar roupa'),
    _Tarefa(id: 5, nome: 'Limpar cozinha'),
  ];

  static const _servico = {
    'cliente': 'João Pedro',
    'data': '29/04/2026',
    'endereco': 'Av. Principal, 456 - Centro',
    'valor': 200,
  };

  int get _concluidas => _tarefas.where((t) => t.concluida).length;
  double get _progresso => _tarefas.isEmpty ? 0 : _concluidas / _tarefas.length;
  int get _progressoPct => (_progresso * 100).round();
  bool get _tudoConcluido => _concluidas == _tarefas.length;

  void _alternar(_Tarefa t) {
    setState(() => t.concluida = !t.concluida);
  }

  Future<void> _finalizar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar serviço'),
        content: const Text(
            'Tem certeza que deseja finalizar este serviço? O cliente será notificado para avaliação.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Serviço finalizado com sucesso!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Execução do Serviço'),
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
            _buildInfoServico(),
            const SizedBox(height: 16),
            _buildProgresso(),
            const SizedBox(height: 16),
            _buildChecklist(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _tudoConcluido ? _finalizar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _tudoConcluido
                      ? 'Finalizar Serviço'
                      : 'Conclua todas as tarefas',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoServico() {
    return Container(
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
      child: Column(
        children: [
          _linhaInfo(
            Icons.person_outline,
            'Cliente',
            _servico['cliente'] as String,
          ),
          const SizedBox(height: 14),
          _linhaInfo(
            Icons.location_on_outlined,
            'Endereço',
            _servico['endereco'] as String,
          ),
          const SizedBox(height: 14),
          _linhaInfo(
            Icons.calendar_today_outlined,
            'Data',
            _servico['data'] as String,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Valor do serviço',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgresso() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '$_progressoPct%',
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
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: _progresso),
              duration: const Duration(milliseconds: 350),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_concluidas de ${_tarefas.length} tarefas concluídas',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Lista de Tarefas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
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
            children: [
              for (int i = 0; i < _tarefas.length; i++) ...[
                _buildItemTarefa(_tarefas[i]),
                if (i < _tarefas.length - 1)
                  Divider(
                    height: 1,
                    indent: 56,
                    color: Colors.grey.shade100,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemTarefa(_Tarefa t) {
    return InkWell(
      onTap: () => _alternar(t),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color:
                    t.concluida ? const Color(0xFF16A34A) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.concluida
                      ? const Color(0xFF16A34A)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: t.concluida
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                t.nome,
                style: TextStyle(
                  fontSize: 15,
                  color: t.concluida ? Colors.grey.shade400 : Colors.black87,
                  decoration: t.concluida ? TextDecoration.lineThrough : null,
                  fontWeight:
                      t.concluida ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
