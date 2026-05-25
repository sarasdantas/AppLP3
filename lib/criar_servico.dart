import 'package:flutter/material.dart';

class CriarServicoPage extends StatefulWidget {
  const CriarServicoPage({super.key});

  @override
  State<CriarServicoPage> createState() => _CriarServicoPageState();
}

class _CriarServicoPageState extends State<CriarServicoPage> {
  final _formKey = GlobalKey<FormState>();
  final _enderecoController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();
  final _novaTarefaController = TextEditingController();

  final List<String> _tarefasSelecionadas = [];

  static const _tarefasPredefinidas = [
    'Limpar banheiro',
    'Lavar louça',
    'Aspirar casa',
    'Passar roupa',
    'Limpar cozinha',
    'Organizar quartos',
  ];

  @override
  void dispose() {
    _enderecoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    _novaTarefaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: agora,
      firstDate: agora,
      lastDate: agora.add(const Duration(days: 90)),
    );
    if (data != null) {
      setState(() {
        _dataController.text =
            '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
      });
    }
  }

  void _adicionarTarefa(String tarefa) {
    final t = tarefa.trim();
    if (t.isEmpty || _tarefasSelecionadas.contains(t)) return;
    setState(() => _tarefasSelecionadas.add(t));
  }

  void _removerTarefa(String tarefa) {
    setState(() => _tarefasSelecionadas.remove(tarefa));
  }

  void _publicar() {
    if (!_formKey.currentState!.validate()) return;
    if (_tarefasSelecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos uma tarefa.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Serviço publicado com sucesso!')),
    );
    Navigator.pushReplacementNamed(context, '/cliente/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          'Nova Faxina',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Data do serviço'),
              _inputField(
                controller: _dataController,
                hint: 'Selecione no calendário',
                readOnly: true,
                onTap: _selecionarData,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a data' : null,
              ),
              const SizedBox(height: 16),
              _label('Endereço'),
              _inputField(
                controller: _enderecoController,
                hint: 'Rua, número, bairro',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe o endereço'
                    : null,
              ),
              const SizedBox(height: 16),
              _label('Valor oferecido (R\$)'),
              _inputField(
                controller: _valorController,
                hint: '150',
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o valor' : null,
              ),
              const SizedBox(height: 20),
              _label('Tarefas rápidas'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tarefasPredefinidas.map((t) {
                  final selecionada = _tarefasSelecionadas.contains(t);
                  return GestureDetector(
                    onTap: () => selecionada
                        ? _removerTarefa(t)
                        : _adicionarTarefa(t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: selecionada
                            ? const Color(0xFFDBEAFE)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${selecionada ? '✓ ' : '+ '}$t',
                        style: TextStyle(
                          color: selecionada
                              ? const Color(0xFF1D4ED8)
                              : Colors.grey.shade800,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _label('Adicionar tarefa personalizada'),
              Row(
                children: [
                  Expanded(
                    child: _inputField(
                      controller: _novaTarefaController,
                      hint: 'Ex: Lavar janelas',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        _adicionarTarefa(_novaTarefaController.text);
                        _novaTarefaController.clear();
                      },
                      child: const SizedBox(
                        width: 54,
                        height: 54,
                        child: Icon(Icons.add,
                            color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                ],
              ),
              if (_tarefasSelecionadas.isNotEmpty) ...[
                const SizedBox(height: 20),
                _label(
                    'Tarefas selecionadas (${_tarefasSelecionadas.length})'),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
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
                      for (int i = 0; i < _tarefasSelecionadas.length; i++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _tarefasSelecionadas[i],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _removerTarefa(_tarefasSelecionadas[i]),
                                icon: const Icon(Icons.close,
                                    size: 20, color: Colors.red),
                                splashRadius: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        if (i < _tarefasSelecionadas.length - 1)
                          Divider(height: 1, color: Colors.grey.shade100),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _publicar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Publicar Faxina',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String texto) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    );
  }
}
