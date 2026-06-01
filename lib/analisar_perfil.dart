import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalisarPerfilPage extends StatefulWidget {
  const AnalisarPerfilPage({super.key});

  @override
  State<AnalisarPerfilPage> createState() => _AnalisarPerfilPageState();
}

class _AnalisarPerfilPageState extends State<AnalisarPerfilPage> {
  @override
  Widget build(BuildContext context) {
    // checagem do usuário atual toda vez que a tela reconstrói
    final User? usuarioAtual = FirebaseAuth.instance.currentUser;

    if (usuarioAtual == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meu Perfil'),
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_rounded, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum usuário conectado no Firebase Auth.\nFaça login novamente para visualizar o perfil.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuarioAtual.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> dadosUser = {};
          if (snapshot.hasData && snapshot.data!.exists) {
            dadosUser = snapshot.data!.data() as Map<String, dynamic>;
          }

          // fallback de segurança caso o documento no fire ainda não exista
          final nomeCompleto =
              dadosUser['nome'] ??
              usuarioAtual.displayName ??
              'Usuário Casa Limpa';
          final email =
              dadosUser['email'] ?? usuarioAtual.email ?? 'Sem e-mail';
          // Rótulo de acesso derivado dos booleanos (o campo 'tipo' foi removido)
          final acessoCliente = dadosUser['acessoCliente'] == true;
          final acessoColaborador = dadosUser['acessoColaborador'] == true;
          final String tipo;
          if (acessoCliente && acessoColaborador) {
            tipo = 'Cliente e Colaborador';
          } else if (acessoColaborador) {
            tipo = 'Colaborador';
          } else {
            tipo = 'Cliente';
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFF2563EB),
                  child: Icon(Icons.person, size: 70, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  nomeCompleto,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Chip(
                  label: Text(
                    tipo.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 32),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF2563EB),
                    ),
                    title: const Text(
                      'E-mail Cadastrado',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    subtitle: Text(
                      email,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
