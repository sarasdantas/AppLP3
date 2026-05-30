import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; // Controla se o modo atual é Login ou Registro
  
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();

  void _autenticar(String tipoUsuario) {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin 
            ? 'Conectado com sucesso como $tipoUsuario!' 
            : 'Conta de $tipoUsuario cadastrada!'),
          backgroundColor: const Color(0xFF6366F1),
        ),
      );

      // Encaminha para o painel principal passando o tipo de perfil definido
      Navigator.pushReplacementNamed(context, '/lista', arguments: tipoUsuario);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipoUsuario = ModalRoute.of(context)!.settings.arguments as String? ?? 'cliente';

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                tipoUsuario == 'cliente' ? Icons.account_circle_rounded : Icons.construction_rounded,
                size: 80,
                color: const Color(0xFF6366F1),
              ),
              const SizedBox(height: 16),
              Text(
                _isLogin ? 'Entrar como ${tipoUsuario.toUpperCase()}' : 'Criar Conta de ${tipoUsuario.toUpperCase()}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nota: Contas de clientes e colaboradores não são compartilhadas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              if (!_isLogin) ...[
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome Completo',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Por favor, informe seu nome' : null,
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.contains('@') ? null : 'Insira um e-mail válido',
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.length < 6 ? 'Mínimo de 6 caracteres' : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _autenticar(tipoUsuario),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_isLogin ? 'Acessar Plataforma' : 'Finalizar Cadastro', style: const TextStyle(fontSize: 16)),
                ),
              ),

              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'Não possui uma conta? Cadastre-se' : 'Já tem um cadastro? Faça login',
                  style: const TextStyle(color: Color(0xFF8B5CF6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}