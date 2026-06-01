import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  // Referência da coleção no Firebase Firestore
  final CollectionReference _firestorePropostas = FirebaseFirestore.instance
      .collection('propostas');
  final CollectionReference _firestoreFaxinas = FirebaseFirestore.instance
      .collection('faxinas');

  // Controladores do formulário de nova proposta
  final _descController = TextEditingController();
  final _valorController = TextEditingController();
  final _endController = TextEditingController();
  final _dataController = TextEditingController();

  int _filtroIndex = 0; // pílula de filtro selecionada
  int _navIndex = 0; // 0 = Propostas, 1 = Faxinas (menu inferior)

  static const Color _azul = Color(0xFF2563EB);

  void _mudarSecao(int index) {
    setState(() {
      _navIndex = index;
      _filtroIndex = 0; // volta o filtro para "Todas" ao trocar de seção
    });
  }

  // Indica se o colaborador atual já recusou esta proposta.
  // A recusa é registrada por colaborador (lista "recusadoPor"), de modo que
  // recusar não remove a proposta do mural dos demais colaboradores.
  bool _euRecusei(Map<String, dynamic> dados, String? uid) {
    final lista = dados['recusadoPor'];
    return uid != null && lista is List && lista.contains(uid);
  }

  // Define quais propostas pertencem à seção atual conforme o papel
  bool _pertenceSecao(bool isCliente, Map<String, dynamic> dados, String? uid) {
    final status = dados['status'] ?? '';
    if (_navIndex == 0) {
      // Coleção "propostas" (negociação). A aceita fica como registro p/ o
      // colaborador ver em "Respondidas"; o cliente vê a sua em Faxinas.
      if (isCliente) {
        return dados['clienteId'] == uid &&
            (status == 'visivel' || status == 'recusado');
      }
      // Colaborador: mural de novas (inclui as que ele recusou, exibidas em
      // "Respondidas") + as que ele mesmo aceitou.
      return status == 'visivel' ||
          (dados['colaboradorId'] == uid &&
              (status == 'aceito' || status == 'recusado'));
    } else {
      // Coleção "faxinas": todo documento já é uma faxina; filtra só por dono.
      if (isCliente) return dados['clienteId'] == uid;
      return dados['colaboradorId'] == uid;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _valorController.dispose();
    _endController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  // ── Filtros por seção (Propostas x Faxinas) ───────────────────────────────
  List<String> _filtrosLabels() {
    return _navIndex == 0
        ? ['Todas', 'Novas', 'Respondidas']
        : ['Todas', 'Pendentes', 'Em andamento', 'Concluídas'];
  }

  // Decide se um documento passa no filtro selecionado
  bool _passaNoFiltro(Map<String, dynamic> dados, String? uid) {
    final status = (dados['status'] ?? '') as String;
    final euRecusei = _euRecusei(dados, uid);
    final label = _filtrosLabels()[_filtroIndex];
    switch (label) {
      case 'Novas':
        // Não mostra como "nova" as propostas que este colaborador já recusou.
        return status == 'visivel' && !euRecusei;
      case 'Respondidas':
        return euRecusei ||
            status == 'recusado' ||
            (status == 'aceito' && dados['colaboradorId'] == uid);
      case 'Pendentes':
        return status == 'aceito' || status == 'pendente';
      case 'Em andamento':
        return status == 'em_andamento';
      case 'Concluídas':
        return status == 'concluido';
      default: // Todas
        return true;
    }
  }

  // ── Envio de nova proposta para o Firestore ───────────────────────────────
  Future<void> _subirPropostaParaFirebase() async {
    if (_descController.text.isNotEmpty &&
        _valorController.text.isNotEmpty &&
        _endController.text.isNotEmpty &&
        _dataController.text.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      await _firestorePropostas.add({
        'descricao': _descController.text.trim(),
        'valor': _valorController.text.trim(),
        'endereco': _endController.text.trim(),
        'data_faxina': _dataController.text.trim(),
        'status': 'visivel',
        'clienteId': user?.uid,
        'clienteNome': user?.displayName ?? user?.email ?? 'Cliente',
        'colaboradorId': null,
        'colaboradorNome': null,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      _descController.clear();
      _valorController.clear();
      _endController.clear();
      _dataController.clear();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposta publicada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _abrirFormularioCadastro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Criar Nova Proposta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),
              _campoForm(_descController, 'O que precisa ser limpo?'),
              const SizedBox(height: 16),
              _campoForm(
                _dataController,
                'Data da Faxina (Ex: 15/06/2026)',
                keyboardType: TextInputType.datetime,
                icon: Icons.calendar_today_rounded,
              ),
              const SizedBox(height: 16),
              _campoForm(
                _valorController,
                'Valor Proposto (R\$)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _campoForm(_endController, 'Endereço da Faxina'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _subirPropostaParaFirebase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _azul,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Publicar Serviço',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _campoForm(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipoUsuario =
        ModalRoute.of(context)!.settings.arguments as String? ?? 'cliente';
    final isCliente = tipoUsuario == 'cliente';
    final titulo = _navIndex == 0 ? 'Propostas' : 'Minhas faxinas';
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header azul curvo ─────────────────────────────────────────────
          Container(
            height: 70,
            decoration: const BoxDecoration(
              color: _azul,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (_navIndex == 0 ? _firestorePropostas : _firestoreFaxinas)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar dados.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filtra pela seção atual do menu (Propostas x Faxinas)
                final visiveis = snapshot.data!.docs.where((doc) {
                  final dados = doc.data() as Map<String, dynamic>;
                  return _pertenceSecao(isCliente, dados, uid);
                }).toList();

                final filtrados = visiveis.where((doc) {
                  final dados = doc.data() as Map<String, dynamic>;
                  return _passaNoFiltro(dados, uid);
                }).toList();

                final subtitulo = _navIndex == 0
                    ? '${visiveis.length} ${visiveis.length == 1 ? 'proposta' : 'propostas'}'
                    : '${visiveis.length} ${visiveis.length == 1 ? 'faxina' : 'faxinas'}';

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/perfil'),
                          icon: const Icon(
                            Icons.account_circle_rounded,
                            size: 34,
                            color: _azul,
                          ),
                          tooltip: 'Meu perfil',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pílulas de filtro
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (var i = 0; i < _filtrosLabels().length; i++)
                          _filtroPill(_filtrosLabels()[i], i),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (filtrados.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Center(
                          child: Text(
                            'Nenhuma ${_navIndex == 0 ? 'proposta' : 'faxina'} nesta categoria.',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final doc in filtrados)
                        _cardProposta(
                          isCliente,
                          doc.id,
                          doc.data() as Map<String, dynamic>,
                          uid,
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(isCliente),
    );
  }

  // ── Pílula de filtro ────────────────────────────────────────────────────
  Widget _filtroPill(String label, int index) {
    final selecionado = _filtroIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filtroIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selecionado ? _azul : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selecionado ? _azul : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selecionado ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  // ── Card de proposta ──────────────────────────────────────────────────────
  Widget _cardProposta(
    bool isCliente,
    String idDocumento,
    Map<String, dynamic> dados,
    String? uid,
  ) {
    final status = (dados['status'] ?? 'visivel') as String;
    final euRecusei = _euRecusei(dados, uid);
    final badge = _badgeInfo(isCliente, status, euRecusei);

    return GestureDetector(
      onTap: () => _abrirDetalhe(isCliente, idDocumento, dados),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    dados['descricao'] ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _statusBadge(badge),
              ],
            ),
            const SizedBox(height: 8),
            // Data/horário + endereço
            Text(
              dados['endereco'] ?? '',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 12),
            // Chip de data
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dados['data_faxina'] ?? 'Data não informada',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 14),
            // Valor + ações
            Row(
              children: [
                Text(
                  'R\$ ${dados['valor']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                ..._acoes(isCliente, idDocumento, dados, uid),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Abre a tela de detalhe/execução conforme a seção e o papel
  void _abrirDetalhe(
    bool isCliente,
    String idDocumento,
    Map<String, dynamic> dados,
  ) {
    if (_navIndex == 0) {
      // Seção Propostas (coleção "propostas")
      if (isCliente) {
        Navigator.pushNamed(
          context,
          '/cliente/detalhes',
          arguments: {'id': idDocumento, 'colecao': 'propostas', ...dados},
        );
      }
      // Colaborador: na seção Propostas usa os botões; sem navegação
    } else {
      // Seção Faxinas (coleção "faxinas")
      final args = {'id': idDocumento, 'colecao': 'faxinas', ...dados};
      Navigator.pushNamed(
        context,
        isCliente ? '/cliente/detalhes' : '/colaborador/detalhes',
        arguments: args,
      );
    }
  }

  // Cria a faxina e marca a proposta como aceita (registro p/ "Respondidas")
  Future<void> _aceitarProposta(
    String idProposta,
    Map<String, dynamic> dados,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final colabId = user?.uid;
    final colabNome = user?.displayName ?? user?.email ?? 'Colaborador';

    await _firestorePropostas.doc(idProposta).update({
      'status': 'aceito',
      'colaboradorId': colabId,
      'colaboradorNome': colabNome,
    });

    await _firestoreFaxinas.add({
      'descricao': dados['descricao'],
      'valor': dados['valor'],
      'endereco': dados['endereco'],
      'data_faxina': dados['data_faxina'],
      'status': 'pendente',
      'clienteId': dados['clienteId'],
      'clienteNome': dados['clienteNome'],
      'colaboradorId': colabId,
      'colaboradorNome': colabNome,
      'propostaId': idProposta,
      'criadoEm': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proposta aceita! Faxina criada.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Recusa individual: registra o colaborador na lista "recusadoPor" sem
  // alterar o status. Assim a proposta continua visível para os outros.
  Future<void> _recusarProposta(String idProposta, String? uid) async {
    if (uid == null) return;
    await _firestorePropostas.doc(idProposta).update({
      'recusadoPor': FieldValue.arrayUnion([uid]),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proposta recusada.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Botões de ação conforme seção/papel/status
  List<Widget> _acoes(
    bool isCliente,
    String idDocumento,
    Map<String, dynamic> dados,
    String? uid,
  ) {
    final status = (dados['status'] ?? 'visivel') as String;

    // Propostas: colaborador recusa/aceita uma proposta nova que ainda não
    // recusou (a recusa é individual e não afeta os demais colaboradores).
    if (_navIndex == 0 &&
        !isCliente &&
        status == 'visivel' &&
        !_euRecusei(dados, uid)) {
      return [
        _botaoAcao('Recusar', const Color(0xFFDC2626), () {
          _recusarProposta(idDocumento, uid);
        }),
        const SizedBox(width: 10),
        _botaoAcao(
          'Aceitar',
          const Color(0xFF16A34A),
          () => _aceitarProposta(idDocumento, dados),
        ),
      ];
    }
    // A conclusão da faxina é feita pelo colaborador (tela de execução).
    return [];
  }

  Widget _botaoAcao(String label, Color cor, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: cor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // ── Badge de status ───────────────────────────────────────────────────────
  Widget _statusBadge(_Badge badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badge.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        badge.label,
        style: TextStyle(
          color: badge.fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _Badge _badgeInfo(bool isCliente, String status, bool euRecusei) {
    // Colaborador que recusou vê a proposta como "Recusada", mesmo que ela
    // continue "visivel" para os demais.
    if (!isCliente && euRecusei && status == 'visivel') {
      return const _Badge('Recusada', Color(0xFFFEE2E2), Color(0xFFDC2626));
    }
    switch (status) {
      case 'aceito':
        return isCliente
            ? const _Badge('Pendente', Color(0xFFFFEDD5), Color(0xFFEA580C))
            : const _Badge('Aceita', Color(0xFFDCFCE7), Color(0xFF16A34A));
      case 'em_andamento':
        return const _Badge(
          'Em andamento',
          Color(0xFFE0E7FF),
          Color(0xFF4F46E5),
        );
      case 'concluido':
        return const _Badge('Concluída', Color(0xFFDCFCE7), Color(0xFF16A34A));
      case 'recusado':
        return const _Badge('Recusada', Color(0xFFFEE2E2), Color(0xFFDC2626));
      default: // visivel
        return const _Badge('Aguardando', Color(0xFFFEF3C7), Color(0xFFA16207));
    }
  }

  // ── Barra de navegação inferior ────────────────────────────────────────────
  Widget _bottomNav(bool isCliente) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: _azul,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            Icons.home_rounded,
            'Propostas',
            ativo: _navIndex == 0,
            onTap: () => _mudarSecao(0),
          ),
          _navItem(
            Icons.cleaning_services_rounded,
            'Faxinas',
            ativo: _navIndex == 1,
            onTap: () => _mudarSecao(1),
          ),
          if (isCliente)
            GestureDetector(
              onTap: _abrirFormularioCadastro,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: _azul, size: 26),
              ),
            ),
          _navItem(
            Icons.logout_rounded,
            'Sair',
            ativo: false,
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label, {
    required bool ativo,
    required VoidCallback onTap,
  }) {
    final cor = ativo ? Colors.white : Colors.white.withValues(alpha: 0.65);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cor, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: cor,
              fontSize: 11,
              fontWeight: ativo ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge {
  final String label;
  final Color bg;
  final Color fg;
  const _Badge(this.label, this.bg, this.fg);
}
