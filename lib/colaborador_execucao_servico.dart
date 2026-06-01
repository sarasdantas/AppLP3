import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ColaboradorExecucaoServicoPage extends StatelessWidget {
  const ColaboradorExecucaoServicoPage({super.key});

  CollectionReference get _faxinas =>
      FirebaseFirestore.instance.collection('faxinas');

  Future<void> _atualizar(
    BuildContext context,
    String idDoc,
    String novoStatus,
    String mensagem, {
    bool fechar = false,
  }) async {
    await _faxinas.doc(idDoc).update({'status': novoStatus});
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: const Color(0xFF16A34A)),
    );
    if (fechar) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String idDocumento = args['id'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Execução do Serviço'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _faxinas.doc(idDocumento).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Serviço não encontrado.'));
          }

          final dados = snapshot.data!.data() as Map<String, dynamic>;
          final status = (dados['status'] ?? 'aceito') as String;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoServico(dados),
                const SizedBox(height: 24),
                _buildAcao(context, idDocumento, status),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAcao(BuildContext context, String idDoc, String status) {
    if (status == 'pendente') {
      return _botao(
        'Iniciar Faxina',
        const Color(0xFF2563EB),
        () => _atualizar(context, idDoc, 'em_andamento', 'Faxina iniciada!'),
      );
    }
    if (status == 'em_andamento') {
      return _botao(
        'Finalizar Serviço',
        const Color(0xFF16A34A),
        () => _atualizar(
          context,
          idDoc,
          'concluido',
          'Serviço finalizado com sucesso!',
          fechar: true,
        ),
      );
    }
    // Concluído (ou outro estado terminal)
    return _botao('Serviço Concluído', Colors.grey.shade400, null);
  }

  Widget _botao(String label, Color cor, VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoServico(Map<String, dynamic> dados) {
    return Container(
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
      child: Column(
        children: [
          _linhaInfo(
            Icons.person_outline,
            'Cliente',
            dados['clienteNome'] ?? 'Cliente',
          ),
          const SizedBox(height: 14),
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
}
