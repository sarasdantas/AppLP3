import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _acessoCliente = false;
  bool _acessoColaborador = false;
  bool _loading = false;
  bool _tipoIniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tipoIniciado) {
      final tipo = ModalRoute.of(context)?.settings.arguments as String?;
      if (tipo == 'colaborador') _acessoColaborador = true;
      if (tipo == 'cliente') _acessoCliente = true;
      _tipoIniciado = true;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acessoCliente && !_acessoColaborador) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ao menos um tipo de acesso.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final tipoUsuario = _acessoColaborador ? 'colaborador' : 'cliente';
    setState(() => _loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _senhaController.text.trim(),
          );

      await credential.user?.updateDisplayName(_nomeController.text.trim());

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(credential.user!.uid)
          .set({
            'id': credential.user!.uid,
            'nome': _nomeController.text.trim(),
            'email': _emailController.text.trim(),
            'acessoCliente': _acessoCliente,
            'acessoColaborador': _acessoColaborador,
            'avaliacaoMedia': _acessoColaborador ? 0.0 : null,
            'criadoEm': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/lista',
        arguments: tipoUsuario,
      );
    } on FirebaseAuthException catch (ex) {
      String mensagem = ex.message ?? 'Erro ao registrar.';
      if (ex.code == 'email-already-in-use') {
        mensagem = 'Este e-mail já está em uso.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cadastrar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Entre com seus dados para continuar',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 36),

              _campo(
                label: 'Nome',
                hint: 'Seu nome',
                controller: _nomeController,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 20),

              _campo(
                label: 'E-mail',
                hint: 'seu@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v != null && v.contains('@'))
                    ? null
                    : 'Insira um e-mail válido',
              ),
              const SizedBox(height: 20),

              _campo(
                label: 'Senha',
                hint: '••••••••••',
                controller: _senhaController,
                obscure: true,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null,
              ),
              const SizedBox(height: 20),

              _campo(
                label: 'Confirmar senha',
                hint: '••••••••••',
                controller: _confirmarController,
                obscure: true,
                validator: (v) =>
                    (v != _senhaController.text) ? 'As senhas não conferem' : null,
              ),
              const SizedBox(height: 28),

              _checkAcesso(
                label: 'Desejo ter acesso de cliente',
                value: _acessoCliente,
                onChanged: (_) => setState(() {
                  _acessoCliente = true;
                  _acessoColaborador = false;
                }),
              ),
              const SizedBox(height: 12),
              _checkAcesso(
                label: 'Desejo ter acesso de colaborador',
                value: _acessoColaborador,
                onChanged: (_) => setState(() {
                  _acessoColaborador = true;
                  _acessoCliente = false;
                }),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _registrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkAcesso({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(true),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF2563EB),
              shape: const CircleBorder(),
              side: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Widget _campo({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
