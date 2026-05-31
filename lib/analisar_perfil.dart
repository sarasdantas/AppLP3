import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AnalisarPerfilPage extends StatefulWidget {
  const AnalisarPerfilPage({super.key});

  @override
  State<AnalisarPerfilPage> createState() => _AnalisarPerfilPageState();
}

class _AnalisarPerfilPageState extends State<AnalisarPerfilPage> {
  bool _carregandoReset = false;
  XFile? _imagemSelecionada;
  final ImagePicker _picker = ImagePicker();

  Future<void> _escolherImagem() async {
    try {
      final XFile? imagem = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (imagem != null) {
        setState(() {
          _imagemSelecionada = imagem;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil alterada com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao selecionar imagem: $e')));
    }
  }

  Future<void> _resetarSenha(String email) async {
    setState(() => _carregandoReset = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('E-mail enviado! 📩'),
          content: Text(
            'Um link de redefinição de senha foi enviado para $email.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar redefinição: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _carregandoReset = false);
    }
  }

  Widget _buildAvatar() {
    if (_imagemSelecionada != null) {
      if (kIsWeb) {
        return CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(_imagemSelecionada!.path),
        );
      } else {
        return CircleAvatar(
          radius: 60,
          backgroundImage: FileImage(File(_imagemSelecionada!.path)),
        );
      }
    }
    return const CircleAvatar(
      radius: 60,
      backgroundColor: Color(0xFF2563EB),
      child: Icon(Icons.person, size: 70, color: Colors.white),
    );
  }

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
          final tipo = dadosUser['tipo'] ?? 'cliente';

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    _buildAvatar(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF2563EB),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                          onPressed: _escolherImagem,
                        ),
                      ),
                    ),
                  ],
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
                    tipo.toString().toUpperCase(),
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
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _carregandoReset
                        ? null
                        : () => _resetarSenha(email),
                    icon: _carregandoReset
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.lock_reset),
                    label: const Text(
                      'Resetar Minha Senha',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
