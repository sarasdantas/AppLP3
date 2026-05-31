import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String _filtroStatus = 'visivel';

class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  // Referência da coleção no Firebase Firestore
  final CollectionReference _firestorePropostas = FirebaseFirestore.instance
      .collection('propostas');

  // Controladores idênticos aos campos que vocês colocaram no Figma
  final _descController = TextEditingController();
  final _valorController = TextEditingController();
  final _endController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    _valorController.dispose();
    _endController.dispose();
    super.dispose();
  }

  // Salva no Firebase Firestore
  Future<void> _subirPropostaParaFirebase() async {
    if (_descController.text.isNotEmpty &&
        _valorController.text.isNotEmpty &&
        _endController.text.isNotEmpty) {
      await _firestorePropostas.add({
        'descricao': _descController.text.trim(),
        'valor': _valorController.text.trim(),
        'endereco': _endController.text.trim(),
        'status': 'visivel',
      });

      _descController.clear();
      _valorController.clear();
      _endController.clear();

      if (!mounted) return;
      Navigator.pop(context); // Fecha o Modal Bottom Sheet de forma segura

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposta publicada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Modal de Cadastro desenhado exatamente igual à segunda tela do seu Figma
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
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'O que precisa ser limpo?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Valor Proposto (R\$)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _endController,
                decoration: InputDecoration(
                  labelText: 'Endereço da Faxina',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _subirPropostaParaFirebase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), // Azul do Figma
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

  @override
  Widget build(BuildContext context) {
    final tipoUsuario =
        ModalRoute.of(context)!.settings.arguments as String? ?? 'cliente';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Fundo cinza claro do Figma
      appBar: AppBar(
        title: Text(
          tipoUsuario == 'cliente'
              ? 'Minhas Propostas'
              : 'Mural de Oportunidades',
        ),
        backgroundColor: const Color(0xFF2563EB), // Azul padrão de vocês
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      // Resgata os dados em tempo real da nuvem do Firebase
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestorePropostas.where('status', isEqualTo: _filtroStatus).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Erro ao carregar dados.'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final documentos = snapshot.data!.docs;

          if (documentos.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma faxina disponível no momento.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              final doc = documentos[index];
              final idDocumento = doc.id;
              final dados = doc.data() as Map<String, dynamic>;

              return InkWell(
                onTap: () {
                  if (tipoUsuario == 'cliente') {
                    Navigator.pushNamed(
                      context,
                      '/cliente/detalhes',
                      arguments: {'id': idDocumento, ...dados},
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/colaborador/detalhes',
                      arguments: {'id': idDocumento, ...dados},
                    );
                  }
                },
                child: Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dados['descricao'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                dados['endereco'] ?? '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'R\$ ${dados['valor']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),

                        // Botões de Ação Direta "Estilo Tinder" do Figma da tela 3
                        if (tipoUsuario == 'colaborador') ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Vaga ocultada.'),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.redAccent,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Recusar',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Altera o status no Firebase e some instantaneamente de todas as telas
                                    await _firestorePropostas
                                        .doc(idDocumento)
                                        .update({'status': 'aceito'});
                                    if (!context.mounted) return;
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Serviço Confirmado! 🎉',
                                        ),
                                        content: const Text(
                                          'Vaga capturada com sucesso diretamente no Cloud Firestore.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF10B981,
                                    ), // Verde Sucesso do Figma
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Aceitar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      // O Botão Azul de Nova Proposta para o Cliente
      floatingActionButton: PopupMenuButton<String>(
        icon: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.menu_open_rounded, color: Colors.white, size: 28),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (String acao) {
          if (acao == 'criar') {
            _abrirFormularioCadastro(); //[cite: 6]
          } else if (acao == 'perfil') {
            Navigator.pushNamed(context, '/perfil');
          } else if (acao == 'mural') {
            setState(() => _filtroStatus = 'visivel');
          } else if (acao == 'aceitas') {
            // Filtra pelo que não está mais aberto no mural
            setState(() => _filtroStatus = 'não iniciada'); 
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'perfil',
            child: ListTile(
              leading: Icon(Icons.person_outline, color: Color(0xFF2563EB)),
              title: Text('Meu Perfil'),
            ),
          ),
          if (tipoUsuario == 'cliente')
            const PopupMenuItem<String>(
              value: 'criar',
              child: ListTile(
                leading: Icon(Icons.add_circle_outline, color: Color(0xFF2563EB)),
                title: Text('Nova Proposta'),
              ),
            ),
          const PopupMenuItem<String>(
            value: 'mural',
            child: ListTile(
              leading: Icon(Icons.blur_on_rounded, color: Color(0xFF2563EB)),
              title: Text('Mural de Oportunidades'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'aceitas',
            child: ListTile(
              leading: Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF2563EB)),
              title: Text('Faxinas Aceitas / Em Andamento'),
            ),
          ),
        ],
      ),
    );
  }
}
