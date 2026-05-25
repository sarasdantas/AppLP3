import 'package:flutter/material.dart';

enum _FiltroOportunidade { todos, perto, melhorValor }

class _Oportunidade {
  final String id;
  final String cliente;
  final String data;
  final String endereco;
  final int valor;
  final int tarefas;
  final double distanciaKm;

  const _Oportunidade({
    required this.id,
    required this.cliente,
    required this.data,
    required this.endereco,
    required this.valor,
    required this.tarefas,
    required this.distanciaKm,
  });
}

class ColaboradorFeedOportunidadesPage extends StatefulWidget {
  const ColaboradorFeedOportunidadesPage({super.key});

  @override
  State<ColaboradorFeedOportunidadesPage> createState() =>
      _ColaboradorFeedOportunidadesPageState();
}

class _ColaboradorFeedOportunidadesPageState
    extends State<ColaboradorFeedOportunidadesPage> {
  _FiltroOportunidade _filtro = _FiltroOportunidade.todos;

  static const _oportunidades = <_Oportunidade>[
    _Oportunidade(
      id: '1',
      cliente: 'João Pedro',
      data: '05/05/2026',
      endereco: 'Rua das Flores, 123 - Centro',
      valor: 150,
      tarefas: 5,
      distanciaKm: 2.3,
    ),
    _Oportunidade(
      id: '4',
      cliente: 'Fernanda Costa',
      data: '06/05/2026',
      endereco: 'Av. Paulista, 1000 - Bela Vista',
      valor: 220,
      tarefas: 8,
      distanciaKm: 5.1,
    ),
    _Oportunidade(
      id: '5',
      cliente: 'Carlos Mendes',
      data: '07/05/2026',
      endereco: 'Rua Augusta, 550 - Consolação',
      valor: 180,
      tarefas: 6,
      distanciaKm: 3.8,
    ),
    _Oportunidade(
      id: '6',
      cliente: 'Patricia Lima',
      data: '08/05/2026',
      endereco: 'Rua Haddock Lobo, 234 - Jardins',
      valor: 200,
      tarefas: 7,
      distanciaKm: 4.2,
    ),
  ];

  List<_Oportunidade> get _ordenadas {
    final lista = [..._oportunidades];
    switch (_filtro) {
      case _FiltroOportunidade.perto:
        lista.sort((a, b) => a.distanciaKm.compareTo(b.distanciaKm));
        break;
      case _FiltroOportunidade.melhorValor:
        lista.sort((a, b) => b.valor.compareTo(a.valor));
        break;
      case _FiltroOportunidade.todos:
        break;
    }
    return lista;
  }

  void _aceitar(_Oportunidade o) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Serviço de ${o.cliente} aceito!')),
    );
    Navigator.pushNamed(
      context,
      '/colaborador/execucao-servico',
      arguments: o.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildFiltros()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverList.separated(
                itemCount: _ordenadas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _buildCardOportunidade(_ordenadas[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Text(
                  'M',
                  style: TextStyle(
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maria Silva',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        SizedBox(width: 4),
                        Text(
                          '4.9',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '(48 avaliações)',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Expanded(child: _StatItem(valor: '127', rotulo: 'Serviços')),
                Expanded(child: _StatItem(valor: '98%', rotulo: 'Aprovação')),
                Expanded(child: _StatItem(valor: 'R\$ 8,4k', rotulo: 'Este mês')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Oportunidades disponíveis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('Todos', _FiltroOportunidade.todos),
                const SizedBox(width: 8),
                _chip('Mais perto', _FiltroOportunidade.perto),
                const SizedBox(width: 8),
                _chip('Melhor valor', _FiltroOportunidade.melhorValor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, _FiltroOportunidade f) {
    final selecionado = _filtro == f;
    return ChoiceChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (_) => setState(() => _filtro = f),
      selectedColor: const Color(0xFF7C3AED),
      labelStyle: TextStyle(
        color: selecionado ? Colors.white : Colors.grey.shade800,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      showCheckmark: false,
    );
  }

  Widget _buildCardOportunidade(_Oportunidade o) {
    return Container(
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
                      o.cliente,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          o.data,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${o.valor}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  Text(
                    '${o.tarefas} tarefas',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined,
                  size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  o.endereco,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _aceitar(o),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Aceitar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _mostrarDetalhes(o),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  side: const BorderSide(
                      color: Color(0xFF7C3AED), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Detalhes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.near_me_outlined,
                  size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${o.distanciaKm.toStringAsFixed(1)} km de você',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarDetalhes(_Oportunidade o) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(o.cliente,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Data: ${o.data}'),
            Text('Endereço: ${o.endereco}'),
            Text('Tarefas previstas: ${o.tarefas}'),
            Text('Distância: ${o.distanciaKm.toStringAsFixed(1)} km'),
            Text('Valor proposto: R\$ ${o.valor}',
                style: const TextStyle(
                    color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _aceitar(o);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Aceitar serviço'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String valor;
  final String rotulo;
  const _StatItem({required this.valor, required this.rotulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          rotulo,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
