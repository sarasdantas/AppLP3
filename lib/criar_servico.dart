import 'package:flutter/material.dart';

class CriarServicoPage extends StatefulWidget {
  const CriarServicoPage({super.key});

  @override
  State<CriarServicoPage> createState() => _CriarServicoPageState();
}

class _CriarServicoPageState extends State<CriarServicoPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para capturar o texto dos inputs
  final _enderecoController = TextEditingController();
  final _dataController = TextEditingController();
  
  // Estados do formulário
  String _tipoFaxina = 'Padrão';
  final Map<String, bool> _tarefasAdicionais = {
    'Lavar e passar roupa': false,
    'Limpar interior da geladeira': false,
    'Limpar interior do forno': false,
    'Limpar janelas e vidros': false,
  };

  @override
  void dispose() {
    _enderecoController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  // Função em Dart para abrir o seletor de calendário nativo do Flutter
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Impede selecionar datas passadas
      lastDate: DateTime.now().add(const Duration(days: 90)), // Limite de 3 meses para frente
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataController.text = 
            "${dataSelecionada.day.toString().padLeft(2, '0')}/${dataSelecionada.month.toString().padLeft(2, '0')}/${dataSelecionada.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Nova Faxina'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tipo de Faxina
              const Text(
                'Tipo de Limpeza',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _tipoFaxina,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.cleaning_services),
                ),
                items: <String>['Padrão', 'Pesada', 'Pós-Obra'].map((String valor) {
                  return DropdownMenuItem<String>(
                    value: valor,
                    child: Text(valor),
                  );
                }).toList(),
                onChanged: (novoValor) {
                  setState(() {
                    _tipoFaxina = novoValor!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // 2. Endereço
              const Text(
                'Endereço da Residência',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  hintText: 'Rua, número, bairro e apto',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o endereço completo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Data da Faxina
              const Text(
                'Data do Serviço',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dataController,
                readOnly: true, // Impede o usuário de digitar texto manual
                decoration: const InputDecoration(
                  hintText: 'Selecione a data no calendário',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selecionarData(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escolha uma data.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 4. Checklist de Tarefas
              const Text(
                'Tarefas Adicionais',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Selecione o que precisa além da limpeza padrão:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              
              // Mapeia dinamicamente o Map de tarefas para widgets de Checkbox
              ..._tarefasAdicionais.keys.map((String tarefa) {
                return CheckboxListTile(
                  title: Text(tarefa),
                  value: _tarefasAdicionais[tarefa],
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (bool? valor) {
                    setState(() {
                      _tarefasAdicionais[tarefa] = valor!;
                    });
                  },
                );
              }),
              const SizedBox(height: 32),

              // Botão de Envio
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Se o formulário for válido, exibe feedback e navega
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Serviço publicado com sucesso!')),
                      );
                      
                      // Retorna o usuário para a Dashboard do Cliente
                      Navigator.pushReplacementNamed(context, '/cliente/dashboard');
                    }
                  },
                  child: const Text(
                    'Publicar Faxina',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}