import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarFaxinaPage extends StatefulWidget {
  const EditarFaxinaPage({super.key});

  @override
  State<EditarFaxinaPage> createState() => _EditarFaxinaPageState();
}

class _EditarFaxinaPageState extends State<EditarFaxinaPage> {
  final _formKey = GlobalKey<FormState>();
  late String _idDocumento;
  late String _statusAtual;
  
  final _descController = TextEditingController();
  final _valorController = TextEditingController();
  final _endController = TextEditingController();
  bool _carregado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_carregado) {
      // Recebe os dados vindos da navegação anterior
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _idDocumento = args['id'];
      _statusAtual = args['status'] ?? 'visivel';
      
      _descController.text = args['descricao'] ?? '';
      _valorController.text = args['valor'] ?? '';
      _endController.text = args['endereco'] ?? '';
      _carregado = true;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _valorController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _salvarEdicao() async {
    if (_formKey.currentState!.validate()) {
      if (_statusAtual != 'visivel') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esta proposta já foi aceita e não pode mais ser editada!'), backgroundColor: Colors.red),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('propostas').doc(_idDocumento).update({
        'descricao': _descController.text.trim(),
        'valor': _valorController.text.trim(),
        'endereco': _endController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposta atualizada com sucesso!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _cancelarProposta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Proposta?'),
        content: const Text('Tem certeza que deseja cancelar esta proposta de faxina definitivamente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Não')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Sim, Cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // Atualiza o status para cancelado no Firebase
      await FirebaseFirestore.instance.collection('propostas').doc(_idDocumento).update({
        'status': 'cancelada',
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposta cancelada com sucesso!'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Editar Proposta'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_statusAtual != 'visivel')
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'Um colaborador já aceitou esta faxina. Bloqueado para edições de texto, mas você ainda pode cancelá-la.',
                    style: TextStyle(color: Colors.amber.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              TextFieldsWidget(controller: _descController, label: 'O que precisa ser limpo?', habilitado: _statusAtual == 'visivel'),
              const SizedBox(height: 16),
              TextFieldsWidget(controller: _valorController, label: 'Valor Proposto (R\$)', tecladoNum: true, habilitado: _statusAtual == 'visivel'),
              const SizedBox(height: 16),
              TextFieldsWidget(controller: _endController, label: 'Endereço da Faxina', habilitado: _statusAtual == 'visivel'),
              const SizedBox(height: 28),
              
              if (_statusAtual == 'visivel') ...[
                ElevatedButton(
                  onPressed: _salvarEdicao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Salvar Alterações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
              ],
              
              OutlinedButton(
                onPressed: _cancelarProposta,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancelar Proposta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextFieldsWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool tecladoNum;
  final bool habilitado;

  const TextFieldsWidget({super.key, required this.controller, required this.label, this.tecladoNum = false, this.habilitado = true});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: habilitado,
      keyboardType: tecladoNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: habilitado ? Colors.white : Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
    );
  }
}