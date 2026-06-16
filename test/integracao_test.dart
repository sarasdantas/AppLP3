// ============================================================
//  test/integracao_test.dart
//  Testes de Integração — Casa Limpa
//  TPS 3: Testes Unitários, Integração e Regressão
//  Fatec Rio Preto — GQS — Prof. Fábio T. Onishi — 2026
//
//  Execução: dart test test/integracao_test.dart
// ============================================================
import 'package:test/test.dart';

// ── Funções reutilizadas dos módulos existentes ──────────────────────────────
// Validadores (de validadores_test.dart)
String? validarEmail(String? v) =>
    (v != null && v.contains('@')) ? null : 'Insira um e-mail válido';

String? validarSenha(String? v) =>
    (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null;

String? validarNome(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null;

String? validarConfirmarSenha(String? v, String senha) =>
    (v != senha) ? 'As senhas não conferem' : null;

// Lógica de status (de logica_status_test.dart)
String rotuloStatus(String status) {
  switch (status) {
    case 'visivel':
      return 'Aguardando';
    case 'aceito':
      return 'Pendente';
    case 'em_andamento':
      return 'Em andamento';
    case 'concluido':
      return 'Concluído';
    case 'recusado':
      return 'Recusada';
    case 'cancelada':
      return 'Cancelada';
    default:
      return status;
  }
}

bool podeEditar(String statusAtual) => statusAtual == 'visivel';

String acaoColaborador(String status) {
  if (status == 'pendente') return 'iniciar';
  if (status == 'em_andamento') return 'finalizar';
  return 'concluido';
}

// Lógica de lista (de logica_lista_test.dart)
bool euRecusei(Map<String, dynamic> dados, String? uid) {
  final lista = dados['recusadoPor'];
  return uid != null && lista is List && lista.contains(uid);
}

bool passaNoFiltro(Map<String, dynamic> dados, String? uid, String label) {
  final status = (dados['status'] ?? '') as String;
  final recusou = euRecusei(dados, uid);
  switch (label) {
    case 'Novas':
      return status == 'visivel' && !recusou;
    case 'Respondidas':
      return recusou ||
          status == 'recusado' ||
          (status == 'aceito' && dados['colaboradorId'] == uid);
    case 'Pendentes':
      return status == 'aceito' || status == 'pendente';
    case 'Em andamento':
      return status == 'em_andamento';
    case 'Concluídas':
      return status == 'concluido';
    default:
      return true;
  }
}

// ── Lógica de acesso (de logica_status_test.dart — regressão) ────────────────
bool temAcesso(Map<String, dynamic>? dados, String tipoUsuario) {
  if (dados == null) return true;
  final acessoCliente = dados['acessoCliente'] == true;
  final acessoColaborador = dados['acessoColaborador'] == true;
  if (acessoCliente || acessoColaborador) {
    return tipoUsuario == 'cliente' ? acessoCliente : acessoColaborador;
  }
  return true;
}

// ══════════════════════════════════════════════════════════════════════════════
//  SIMULADORES DE INTEGRAÇÃO
//  Simulam a interação entre módulos como ocorreria no app real.
// ══════════════════════════════════════════════════════════════════════════════

/// Simula o fluxo completo de registro de usuário:
/// valida nome, email, senha e confirmação de senha.
/// Retorna null se tudo OK, ou a primeira mensagem de erro encontrada.
String? fluxoRegistro(String nome, String email, String senha, String confirmar) {
  return validarNome(nome) ??
      validarEmail(email) ??
      validarSenha(senha) ??
      validarConfirmarSenha(confirmar, senha);
}

/// Simula o fluxo completo de login:
/// valida credenciais + verifica acesso por tipo de usuário.
/// Retorna um Map com 'sucesso' (bool) e 'mensagem' (String).
Map<String, dynamic> fluxoLogin(
  String email,
  String senha,
  Map<String, dynamic>? dadosFirestore,
  String tipoUsuario,
) {
  final erroEmail = validarEmail(email);
  if (erroEmail != null) return {'sucesso': false, 'mensagem': erroEmail};

  final erroSenha = validarSenha(senha);
  if (erroSenha != null) return {'sucesso': false, 'mensagem': erroSenha};

  if (!temAcesso(dadosFirestore, tipoUsuario)) {
    return {'sucesso': false, 'mensagem': 'Acesso negado para este tipo de conta'};
  }

  return {'sucesso': true, 'mensagem': 'Login realizado com sucesso'};
}

/// Simula o ciclo de vida completo de uma faxina:
/// criação → aceite → início → conclusão, verificando status e filtros em cada etapa.
class CicloFaxina {
  Map<String, dynamic> dados;
  CicloFaxina()
      : dados = {
          'status': 'visivel',
          'recusadoPor': <String>[],
          'colaboradorId': null,
        };

  String get statusAtual => dados['status'] as String;
  String get rotulo => rotuloStatus(statusAtual);
  bool get editavel => podeEditar(statusAtual);

  void aceitar(String colaboradorId) {
    dados['status'] = 'aceito';
    dados['colaboradorId'] = colaboradorId;
  }

  void iniciar() {
    dados['status'] = 'em_andamento';
  }

  void concluir() {
    dados['status'] = 'concluido';
  }

  void recusar(String colaboradorId) {
    (dados['recusadoPor'] as List).add(colaboradorId);
  }

  void cancelar() {
    dados['status'] = 'cancelada';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  TESTES DE INTEGRAÇÃO
// ══════════════════════════════════════════════════════════════════════════════
void main() {
  // ── INT-001 a INT-004 | Fluxo de Registro ─────────────────────────────────
  group('INT-001 a INT-004 | Fluxo completo de Registro', () {
    test('INT-001: registro com todos os campos válidos retorna null (sucesso)', () {
      expect(
        fluxoRegistro('Maria Silva', 'maria@email.com', 'senha123', 'senha123'),
        isNull,
      );
    });

    test('INT-002: registro com nome vazio falha na primeira validação', () {
      expect(
        fluxoRegistro('', 'maria@email.com', 'senha123', 'senha123'),
        equals('Informe seu nome'),
      );
    });

    test('INT-003: registro com email inválido falha na segunda validação', () {
      expect(
        fluxoRegistro('Maria Silva', 'emailinvalido', 'senha123', 'senha123'),
        equals('Insira um e-mail válido'),
      );
    });

    test('INT-004: registro com senhas diferentes falha na confirmação', () {
      expect(
        fluxoRegistro('Maria Silva', 'maria@email.com', 'senha123', 'outra456'),
        equals('As senhas não conferem'),
      );
    });
  });

  // ── INT-005 a INT-008 | Fluxo de Login ─────────────────────────────────────
  group('INT-005 a INT-008 | Fluxo completo de Login + Verificação de Acesso', () {
    test('INT-005: login de cliente válido com acesso permitido', () {
      final dadosFirestore = {'acessoCliente': true, 'acessoColaborador': false};
      final resultado = fluxoLogin('user@email.com', 'senha123', dadosFirestore, 'cliente');
      expect(resultado['sucesso'], isTrue);
      expect(resultado['mensagem'], equals('Login realizado com sucesso'));
    });

    test('INT-006: login com email inválido é barrado antes da verificação de acesso', () {
      final dadosFirestore = {'acessoCliente': true, 'acessoColaborador': false};
      final resultado = fluxoLogin('emailinvalido', 'senha123', dadosFirestore, 'cliente');
      expect(resultado['sucesso'], isFalse);
      expect(resultado['mensagem'], equals('Insira um e-mail válido'));
    });

    test('INT-007: login com senha curta é barrado antes da verificação de acesso', () {
      final dadosFirestore = {'acessoCliente': true, 'acessoColaborador': false};
      final resultado = fluxoLogin('user@email.com', '123', dadosFirestore, 'cliente');
      expect(resultado['sucesso'], isFalse);
      expect(resultado['mensagem'], equals('Mínimo de 6 caracteres'));
    });

    test('INT-008: login de cliente tentando acessar como colaborador é bloqueado', () {
      final dadosFirestore = {'acessoCliente': true, 'acessoColaborador': false};
      final resultado = fluxoLogin('user@email.com', 'senha123', dadosFirestore, 'colaborador');
      expect(resultado['sucesso'], isFalse);
      expect(resultado['mensagem'], equals('Acesso negado para este tipo de conta'));
    });
  });

  // ── INT-009 a INT-014 | Ciclo de Vida da Faxina ────────────────────────────
  group('INT-009 a INT-014 | Ciclo de vida completo de uma Faxina', () {
    const colabId = 'uid_colab_1';
    const colabId2 = 'uid_colab_2';

    test('INT-009: faxina recém-criada está visível, editável e aparece em "Novas"', () {
      final faxina = CicloFaxina();
      expect(faxina.statusAtual, equals('visivel'));
      expect(faxina.rotulo, equals('Aguardando'));
      expect(faxina.editavel, isTrue);
      expect(passaNoFiltro(faxina.dados, colabId, 'Novas'), isTrue);
    });

    test('INT-010: após aceite, status muda, não é mais editável e aparece em "Pendentes"', () {
      final faxina = CicloFaxina();
      faxina.aceitar(colabId);
      expect(faxina.statusAtual, equals('aceito'));
      expect(faxina.rotulo, equals('Pendente'));
      expect(faxina.editavel, isFalse);
      expect(passaNoFiltro(faxina.dados, colabId, 'Pendentes'), isTrue);
      expect(passaNoFiltro(faxina.dados, colabId, 'Novas'), isFalse);
    });

    test('INT-011: após iniciar, aparece em "Em andamento" e ação é "finalizar"', () {
      final faxina = CicloFaxina();
      faxina.aceitar(colabId);
      faxina.iniciar();
      expect(faxina.statusAtual, equals('em_andamento'));
      expect(faxina.rotulo, equals('Em andamento'));
      expect(acaoColaborador(faxina.statusAtual), equals('finalizar'));
      expect(passaNoFiltro(faxina.dados, colabId, 'Em andamento'), isTrue);
    });

    test('INT-012: após concluir, aparece em "Concluídas" e não é mais editável', () {
      final faxina = CicloFaxina();
      faxina.aceitar(colabId);
      faxina.iniciar();
      faxina.concluir();
      expect(faxina.statusAtual, equals('concluido'));
      expect(faxina.rotulo, equals('Concluído'));
      expect(faxina.editavel, isFalse);
      expect(passaNoFiltro(faxina.dados, colabId, 'Concluídas'), isTrue);
      expect(passaNoFiltro(faxina.dados, colabId, 'Em andamento'), isFalse);
    });

    test('INT-013: colaborador que recusou não vê em "Novas", mas outro colaborador vê', () {
      final faxina = CicloFaxina();
      faxina.recusar(colabId);
      expect(passaNoFiltro(faxina.dados, colabId, 'Novas'), isFalse);
      expect(passaNoFiltro(faxina.dados, colabId, 'Respondidas'), isTrue);
      expect(passaNoFiltro(faxina.dados, colabId2, 'Novas'), isTrue);
    });

    test('INT-014: faxina cancelada não aparece em filtros ativos', () {
      final faxina = CicloFaxina();
      faxina.cancelar();
      expect(faxina.rotulo, equals('Cancelada'));
      expect(passaNoFiltro(faxina.dados, colabId, 'Novas'), isFalse);
      expect(passaNoFiltro(faxina.dados, colabId, 'Pendentes'), isFalse);
      expect(passaNoFiltro(faxina.dados, colabId, 'Em andamento'), isFalse);
      expect(passaNoFiltro(faxina.dados, colabId, 'Concluídas'), isFalse);
      // mas aparece em "Todas"
      expect(passaNoFiltro(faxina.dados, colabId, 'Todas'), isTrue);
    });
  });
}
