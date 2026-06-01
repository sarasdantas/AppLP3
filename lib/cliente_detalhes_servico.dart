import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteDetalhesServicoPage extends StatelessWidget {
  const ClienteDetalhesServicoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String idDocumento = args['id'] ?? '';
    final String nomeColecao = args['colecao'] ?? 'propostas';
    final CollectionReference colecao =
        FirebaseFirestore.instance.collection(nomeColecao);

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: colecao.doc(idDocumento).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Serviço não encontrado.'));
          }

          final dados = snapshot.data!.data() as Map<String, dynamic>;
          final status = (dados['status'] ?? 'visivel') as String;
          final colaborador = dados['colaboradorNome'] as String?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardColaborador(status, colaborador),
                const SizedBox(height: 12),
                _buildCardInfo(dados),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<DocumentSnapshot>(
        stream: colecao.doc(idDocumento).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const SizedBox.shrink();
          }
          final dados = snapshot.data!.data() as Map<String, dynamic>;
          final status = (dados['status'] ?? 'visivel') as String;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildBotoesFluxo(
              context,
              colecao,
              idDocumento,
              status,
              dados,
            ),
          );
        },
      ),
    );
  }

  // ── Ações conforme o status ─────────────────────────────────────────────
  Widget _buildBotoesFluxo(
    BuildContext context,
    CollectionReference colecao,
    String idDoc,
    String status,
    Map<String, dynamic> dados,
  ) {
    if (status == 'visivel') {
      // Proposta ainda aberta: pode editar ou cancelar
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                '/editar',
                arguments: {
                  'id': idDoc,
                  'status': status,
                  'descricao': dados['descricao'],
                  'valor': dados['valor'],
                  'endereco': dados['endereco'],
                },
              ),
              child: const Text('Editar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _mudarStatus(
                context,
                colecao,
                idDoc,
                'cancelada',
                'Proposta cancelada.',
              ),
              child: const Text('Cancelar'),
            ),
          ),
        ],
      );
    } else if (status == 'aceito') {
      // Colaborador aceitou, mas ainda não iniciou
      return _caixaInfo('Aguardando o colaborador iniciar a faxina.');
    } else if (status == 'em_andamento') {
      // Em execução: só o colaborador pode finalizar
      return _caixaInfo('Faxina em andamento. Aguarde o colaborador finalizar.');
    }

    return _caixaInfo(
      'Serviço finalizado com o status: ${_rotuloStatus(status).toUpperCase()}',
    );
  }

  Widget _caixaInfo(String texto) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Future<void> _mudarStatus(
    BuildContext context,
    CollectionReference colecao,
    String idDoc,
    String novoStatus,
    String mensagem,
  ) async {
    await colecao.doc(idDoc).update({'status': novoStatus});
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  // ── Cards ─────────────────────────────────────────────────────────────────
  Widget _cardBase({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardColaborador(String status, String? colaborador) {
    final temColaborador = colaborador != null && colaborador.isNotEmpty;
    return _cardBase(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFEDE9FE),
            child: Text(
              temColaborador ? colaborador.characters.first.toUpperCase() : '?',
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
                  temColaborador ? colaborador : 'Aguardando colaborador',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  temColaborador ? 'Colaborador(a)' : 'Nenhum profissional ainda',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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

  Widget _buildCardInfo(Map<String, dynamic> dados) {
    return _cardBase(
      child: Column(
        children: [
          _linhaInfo(
            Icons.cleaning_services_outlined,
            'Serviço',
            dados['descricao'] ?? '',
          ),
          const SizedBox(height: 14),
          _linhaInfo(
            Icons.location_on_outlined,
            'Endereço',
            dados['endereco'] ?? '',
          ),
          const SizedBox(height: 14),
          _linhaInfo(
            Icons.calendar_today_outlined,
            'Data',
            dados['data_faxina'] ?? 'Não informada',
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
                'R\$ ${dados['valor']}',
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
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                valor,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _rotuloStatus(String status) {
    switch (status) {
      case 'visivel':
        return 'Aguardando';
      case 'aceito':
        return 'Pendente';
      case 'em_andamento':
        return 'Em andamento';
      case 'concluido':
        return 'Concluído';
      case 'recusado':
        return 'Recusada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return status;
    }
  }

  Widget _badgeStatus(String status) {
    final (corFundo, corTexto) = switch (status) {
      'visivel' => (const Color(0xFFFEF3C7), const Color(0xFFA16207)),
      'aceito' => (const Color(0xFFFFEDD5), const Color(0xFFEA580C)),
      'em_andamento' => (const Color(0xFFE0E7FF), const Color(0xFF4F46E5)),
      'concluido' => (const Color(0xFFDCFCE7), const Color(0xFF15803D)),
      'recusado' => (const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
      'cancelada' => (const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
      _ => (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _rotuloStatus(status),
        style: TextStyle(
          color: corTexto,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
