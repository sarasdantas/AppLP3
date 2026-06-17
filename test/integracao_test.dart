// ============================================================
//  test/integracao_test.dart
//  Testes de Integração com Mockito — Casa Limpa
//  TPS 3: Testes Unitários, Integração e Regressão
//  Fatec Rio Preto — GQS — Prof. Fábio T. Onishi — 2026
//
//  Execução:
//    1) flutter pub run build_runner build --delete-conflicting-outputs
//    2) dart test test/integracao_test.dart
// ============================================================
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'integracao_test.mocks.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  CAMADA DE DOMÍNIO + SERVIÇOS
// ══════════════════════════════════════════════════════════════════════════════
class Validador {
  String? validarEmail(String? v) =>
      (v != null && v.contains('@')) ? null : 'Insira um e-mail válido';
  String? validarSenha(String? v) =>
      (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null;
  String? validarNome(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null;
  String? validarConfirmarSenha(String? v, String s) =>
      (v != s) ? 'As senhas não conferem' : null;
}

abstract class AuthService {
  /// Faz login no provedor (Firebase Auth) e retorna o uid, ou null se falhar.
  Future<String?> login(String email, String senha);

  /// Cria um novo usuário e retorna o uid.
  Future<String> registrar(String email, String senha);
}

abstract class FirestoreService {
  Future<Map<String, dynamic>?> obterUsuario(String uid);
  Future<void> salvarUsuario(String uid, Map<String, dynamic> dados);
  Future<void> atualizarStatusFaxina(String faxinaId, String novoStatus);
}

// Fluxo de Registro: usa Validador + AuthService + FirestoreService
class RegistroFlow {
  final Validador validador;
  final AuthService auth;
  final FirestoreService firestore;
  RegistroFlow(this.validador, this.auth, this.firestore);

  Future<String?> executar({
    required String nome,
    required String email,
    required String senha,
    required String confirmar,
  }) async {
    final erro = validador.validarNome(nome) ??
        validador.validarEmail(email) ??
        validador.validarSenha(senha) ??
        validador.validarConfirmarSenha(confirmar, senha);
    if (erro != null) return erro;

    final uid = await auth.registrar(email, senha);
    await firestore.salvarUsuario(uid, {
      'nome': nome,
      'email': email,
      'acessoCliente': true,
      'acessoColaborador': false,
    });
    return null;
  }
}

// Fluxo de Login
class LoginFlow {
  final Validador validador;
  final AuthService auth;
  final FirestoreService firestore;
  LoginFlow(this.validador, this.auth, this.firestore);

  Future<Map<String, dynamic>> executar(
      String email, String senha, String tipoUsuario) async {
    final erroEmail = validador.validarEmail(email);
    if (erroEmail != null) return {'sucesso': false, 'mensagem': erroEmail};
    final erroSenha = validador.validarSenha(senha);
    if (erroSenha != null) return {'sucesso': false, 'mensagem': erroSenha};

    final uid = await auth.login(email, senha);
    if (uid == null) {
      return {'sucesso': false, 'mensagem': 'Credenciais inválidas'};
    }

    final dados = await firestore.obterUsuario(uid);
    if (dados != null) {
      final ac = dados['acessoCliente'] == true;
      final aco = dados['acessoColaborador'] == true;
      if (ac || aco) {
        final ok = tipoUsuario == 'cliente' ? ac : aco;
        if (!ok) {
          return {
            'sucesso': false,
            'mensagem': 'Acesso negado para este tipo de conta'
          };
        }
      }
    }
    return {'sucesso': true, 'mensagem': 'Login realizado com sucesso'};
  }
}

// Ciclo de Faxina — persiste mudanças via FirestoreService
class CicloFaxina {
  final FirestoreService firestore;
  final String faxinaId;
  String status;
  CicloFaxina(this.firestore, this.faxinaId) : status = 'visivel';

  Future<void> aceitar() async {
    status = 'aceito';
    await firestore.atualizarStatusFaxina(faxinaId, status);
  }

  Future<void> iniciar() async {
    status = 'em_andamento';
    await firestore.atualizarStatusFaxina(faxinaId, status);
  }

  Future<void> concluir() async {
    status = 'concluido';
    await firestore.atualizarStatusFaxina(faxinaId, status);
  }

  Future<void> cancelar() async {
    status = 'cancelada';
    await firestore.atualizarStatusFaxina(faxinaId, status);
  }
}

@GenerateMocks([Validador, AuthService, FirestoreService])
void main() {
  late MockValidador mockValidador;
  late MockAuthService mockAuth;
  late MockFirestoreService mockFirestore;

  setUp(() {
    mockValidador = MockValidador();
    mockAuth = MockAuthService();
    mockFirestore = MockFirestoreService();
  });

  // ── INT-001 a INT-004 | Fluxo de Registro ─────────────────────────────────
  group('INT-001 a INT-004 | RegistroFlow com mocks', () {
    test('INT-001: registro válido salva no Firestore e retorna null', () async {
      when(mockValidador.validarNome(any)).thenReturn(null);
      when(mockValidador.validarEmail(any)).thenReturn(null);
      when(mockValidador.validarSenha(any)).thenReturn(null);
      when(mockValidador.validarConfirmarSenha(any, any)).thenReturn(null);
      when(mockAuth.registrar('maria@email.com', 'senha123'))
          .thenAnswer((_) async => 'uid_maria');
      when(mockFirestore.salvarUsuario(any, any)).thenAnswer((_) async {
        return null;
      });

      final flow = RegistroFlow(mockValidador, mockAuth, mockFirestore);
      final r = await flow.executar(
        nome: 'Maria Silva',
        email: 'maria@email.com',
        senha: 'senha123',
        confirmar: 'senha123',
      );

      expect(r, isNull);
      verify(mockAuth.registrar('maria@email.com', 'senha123')).called(1);
      verify(mockFirestore.salvarUsuario('uid_maria', argThat(predicate(
              (Map m) => m['nome'] == 'Maria Silva' && m['acessoCliente'] == true))))
          .called(1);
    });

    test('INT-002: nome vazio falha e NÃO chama Auth/Firestore', () async {
      when(mockValidador.validarNome(''))
          .thenReturn('Informe seu nome');

      final flow = RegistroFlow(mockValidador, mockAuth, mockFirestore);
      final r = await flow.executar(
        nome: '',
        email: 'x@y.com',
        senha: 'senha123',
        confirmar: 'senha123',
      );

      expect(r, equals('Informe seu nome'));
      verifyNever(mockAuth.registrar(any, any));
      verifyNever(mockFirestore.salvarUsuario(any, any));
    });

    test('INT-003: email inválido => Auth não é chamado', () async {
      when(mockValidador.validarNome(any)).thenReturn(null);
      when(mockValidador.validarEmail(any))
          .thenReturn('Insira um e-mail válido');

      final flow = RegistroFlow(mockValidador, mockAuth, mockFirestore);
      final r = await flow.executar(
        nome: 'Maria',
        email: 'invalido',
        senha: 'senha123',
        confirmar: 'senha123',
      );

      expect(r, equals('Insira um e-mail válido'));
      verifyZeroInteractions(mockAuth);
      verifyZeroInteractions(mockFirestore);
    });

    test('INT-004: senhas diferentes => não chama Auth nem Firestore', () async {
      when(mockValidador.validarNome(any)).thenReturn(null);
      when(mockValidador.validarEmail(any)).thenReturn(null);
      when(mockValidador.validarSenha(any)).thenReturn(null);
      when(mockValidador.validarConfirmarSenha('outra456', 'senha123'))
          .thenReturn('As senhas não conferem');

      final flow = RegistroFlow(mockValidador, mockAuth, mockFirestore);
      final r = await flow.executar(
        nome: 'Maria',
        email: 'm@e.com',
        senha: 'senha123',
        confirmar: 'outra456',
      );

      expect(r, equals('As senhas não conferem'));
      verifyNever(mockAuth.registrar(any, any));
    });
  });

  // ── INT-005 a INT-008 | Fluxo de Login ────────────────────────────────────
  group('INT-005 a INT-008 | LoginFlow com mocks', () {
    test('INT-005: cliente válido com acesso permitido', () async {
      when(mockValidador.validarEmail(any)).thenReturn(null);
      when(mockValidador.validarSenha(any)).thenReturn(null);
      when(mockAuth.login('user@email.com', 'senha123'))
          .thenAnswer((_) async => 'uid_user');
      when(mockFirestore.obterUsuario('uid_user')).thenAnswer(
          (_) async => {'acessoCliente': true, 'acessoColaborador': false});

      final r = await LoginFlow(mockValidador, mockAuth, mockFirestore)
          .executar('user@email.com', 'senha123', 'cliente');

      expect(r['sucesso'], isTrue);
      expect(r['mensagem'], equals('Login realizado com sucesso'));
      verify(mockAuth.login('user@email.com', 'senha123')).called(1);
      verify(mockFirestore.obterUsuario('uid_user')).called(1);
    });

    test('INT-006: email inválido barra antes do Auth', () async {
      when(mockValidador.validarEmail('emailinvalido'))
          .thenReturn('Insira um e-mail válido');

      final r = await LoginFlow(mockValidador, mockAuth, mockFirestore)
          .executar('emailinvalido', 'senha123', 'cliente');

      expect(r['sucesso'], isFalse);
      expect(r['mensagem'], equals('Insira um e-mail válido'));
      verifyZeroInteractions(mockAuth);
      verifyZeroInteractions(mockFirestore);
    });

    test('INT-007: senha curta barra antes do Auth', () async {
      when(mockValidador.validarEmail(any)).thenReturn(null);
      when(mockValidador.validarSenha('123'))
          .thenReturn('Mínimo de 6 caracteres');

      final r = await LoginFlow(mockValidador, mockAuth, mockFirestore)
          .executar('user@email.com', '123', 'cliente');

      expect(r['sucesso'], isFalse);
      expect(r['mensagem'], equals('Mínimo de 6 caracteres'));
      verifyZeroInteractions(mockAuth);
    });

    test('INT-008: cliente tentando acessar como colaborador é bloqueado',
        () async {
      when(mockValidador.validarEmail(any)).thenReturn(null);
      when(mockValidador.validarSenha(any)).thenReturn(null);
      when(mockAuth.login(any, any)).thenAnswer((_) async => 'uid_user');
      when(mockFirestore.obterUsuario('uid_user')).thenAnswer(
          (_) async => {'acessoCliente': true, 'acessoColaborador': false});

      final r = await LoginFlow(mockValidador, mockAuth, mockFirestore)
          .executar('user@email.com', 'senha123', 'colaborador');

      expect(r['sucesso'], isFalse);
      expect(r['mensagem'], equals('Acesso negado para este tipo de conta'));
    });

    test('Credenciais inválidas no Auth => login falha', () async {
      when(mockValidador.validarEmail(any)).thenReturn(null);
      when(mockValidador.validarSenha(any)).thenReturn(null);
      when(mockAuth.login(any, any)).thenAnswer((_) async => null);

      final r = await LoginFlow(mockValidador, mockAuth, mockFirestore)
          .executar('user@email.com', 'senha123', 'cliente');

      expect(r['sucesso'], isFalse);
      expect(r['mensagem'], equals('Credenciais inválidas'));
      verifyNever(mockFirestore.obterUsuario(any));
    });
  });

  // ── INT-009 a INT-014 | Ciclo de vida da Faxina ───────────────────────────
  group('INT-009 a INT-014 | CicloFaxina com FirestoreService mockado', () {
    test('INT-009: faxina recém-criada está visível', () {
      final f = CicloFaxina(mockFirestore, 'fx1');
      expect(f.status, equals('visivel'));
      verifyZeroInteractions(mockFirestore);
    });

    test('INT-010: aceitar() muda status e persiste', () async {
      when(mockFirestore.atualizarStatusFaxina(any, any))
          .thenAnswer((_) async {
            return null;
          });
      final f = CicloFaxina(mockFirestore, 'fx1');

      await f.aceitar();

      expect(f.status, equals('aceito'));
      verify(mockFirestore.atualizarStatusFaxina('fx1', 'aceito')).called(1);
    });

    test('INT-011: iniciar() persiste "em_andamento"', () async {
      when(mockFirestore.atualizarStatusFaxina(any, any))
          .thenAnswer((_) async {
            return null;
          });
      final f = CicloFaxina(mockFirestore, 'fx1');

      await f.aceitar();
      await f.iniciar();

      expect(f.status, equals('em_andamento'));
      verify(mockFirestore.atualizarStatusFaxina('fx1', 'em_andamento'))
          .called(1);
    });

    test('INT-012: concluir() persiste "concluido"', () async {
      when(mockFirestore.atualizarStatusFaxina(any, any))
          .thenAnswer((_) async {
            return null;
          });
      final f = CicloFaxina(mockFirestore, 'fx1');

      await f.aceitar();
      await f.iniciar();
      await f.concluir();

      expect(f.status, equals('concluido'));
      // Verifica a ORDEM das chamadas
      verifyInOrder([
        mockFirestore.atualizarStatusFaxina('fx1', 'aceito'),
        mockFirestore.atualizarStatusFaxina('fx1', 'em_andamento'),
        mockFirestore.atualizarStatusFaxina('fx1', 'concluido'),
      ]);
    });

    test('INT-014: cancelar() persiste "cancelada"', () async {
      when(mockFirestore.atualizarStatusFaxina(any, any))
          .thenAnswer((_) async {
            return null;
          });
      final f = CicloFaxina(mockFirestore, 'fx1');

      await f.cancelar();

      expect(f.status, equals('cancelada'));
      verify(mockFirestore.atualizarStatusFaxina('fx1', 'cancelada')).called(1);
      verifyNoMoreInteractions(mockFirestore);
    });
  });
}
