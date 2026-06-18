import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Confere no Firestore se o usuário pode entrar com o papel escolhido.
  Future<bool> _temAcesso(String uid, String tipoUsuario) async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();
    final dados = doc.data();
    if (dados == null) return true; // sem registro: não bloqueia

    final acessoCliente = dados['acessoCliente'] == true;
    final acessoColaborador = dados['acessoColaborador'] == true;

    if (acessoCliente || acessoColaborador) {
      return tipoUsuario == 'cliente' ? acessoCliente : acessoColaborador;
    }
    return true; // conta antiga sem campos de acesso: não bloqueia
  }

  
Future<void> _autenticar(String tipoUsuario) async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  try {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _senhaController.text.trim(),
    );

    final acessoLiberado = await _temAcesso(cred.user!.uid, tipoUsuario);

    if (!acessoLiberado) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;

      final outro = tipoUsuario == 'cliente' ? 'colaborador' : 'cliente';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Esta conta não tem acesso de $tipoUsuario. '
            'Tente entrar como $outro ou cadastre esse acesso.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/lista',
      arguments: tipoUsuario,
    );
  } on FirebaseAuthException catch (ex) {
    String mensagem;
    switch (ex.code) {
      case 'invalid-email':
        mensagem = 'E-mail inválido.';
        break;
      case 'user-disabled':
        mensagem = 'Esta conta foi desativada.';
        break;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        mensagem = 'E-mail ou senha incorretos.';
        break;
      default:
        mensagem = ex.message ?? 'Não foi possível entrar.';
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao abrir o dashboard: $e'),
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
    final tipoUsuario =
        ModalRoute.of(context)!.settings.arguments as String? ?? 'cliente';

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
              Text(
                'Entrar como $tipoUsuario',
                style: const TextStyle(
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
                label: 'E-mail',
                hint: 'seu@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v != null && v.contains('@')) ? null : 'Insira um e-mail válido',
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
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : () => _autenticar(tipoUsuario),
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
                          'Entrar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/registro',
                    arguments: tipoUsuario,
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: 'Não tem conta? ',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      children: const [
                        TextSpan(
                          text: 'Cadastre-se',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _campo({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
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
