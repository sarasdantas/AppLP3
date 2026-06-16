// ============================================================
//  test/regressao_test.dart
//  Testes de Regressão — Casa Limpa
//  TPS 3: Testes Unitários, Integração e Regressão
//  Fatec Rio Preto — GQS — Prof. Fábio T. Onishi — 2026
//
//  Execução: dart test test/regressao_test.dart
// ============================================================
import 'package:test/test.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  FUNÇÕES DO SISTEMA (reutilizadas para testes de regressão)
// ══════════════════════════════════════════════════════════════════════════════

// Validadores
String? validarEmail(String? v) =>
    (v != null && v.contains('@')) ? null : 'Insira um e-mail válido';

String? validarSenha(String? v) =>
    (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null;

String? validarConfirmarSenha(String? v, String senha) =>
    (v != senha) ? 'As senhas não conferem' : null;

String? validarNome(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null;

// Lógica de status
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

// Lógica de lista
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

// Lógica de acesso
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
//  TESTES DE REGRESSÃO
//  Objetivo: garantir que funcionalidades existentes continuem funcionando
//  corretamente após alterações, correções de bugs ou adição de novas features.
// ══════════════════════════════════════════════════════════════════════════════
void main() {
  // ── REG-001 a REG-003 | Regressão de Validadores ──────────────────────────
  // Cenário: após refatoração dos validadores, garantir que regras de negócio
  // originais foram preservadas.
  group('REG-001 a REG-003 | Regressão — Validadores após refatoração', () {
    test('REG-001: e-mails com caracteres especiais antes do @ continuam válidos', () {
      expect(validarEmail('user.name+tag@email.com'), isNull);
      expect(validarEmail('user_name@domain.co'), isNull);
    });

    test('REG-002: senha com exatamente 6 caracteres (valor limite) continua válida', () {
      // Bug anterior: operador < foi trocado por <= durante refatoração
      expect(validarSenha('123456'), isNull);
      expect(validarSenha('12345'), equals('Mínimo de 6 caracteres'));
    });

    test('REG-003: nome com espaços em branco continua sendo rejeitado', () {
      // Bug anterior: trim() foi removido acidentalmente
      expect(validarNome('   '), equals('Informe seu nome'));
      expect(validarNome('\t'), equals('Informe seu nome'));
    });
  });

  // ── REG-004 a REG-006 | Regressão de Acesso ───────────────────────────────
  // Cenário: após adição de novo tipo de usuário "admin", garantir que lógica
  // de acesso existente para cliente/colaborador não foi quebrada.
  group('REG-004 a REG-006 | Regressão — Lógica de acesso (temAcesso)', () {
    test('REG-004: cliente com acesso permitido continua acessando após mudanças', () {
      final dados = {'acessoCliente': true, 'acessoColaborador': false};
      expect(temAcesso(dados, 'cliente'), isTrue);
    });

    test('REG-005: colaborador sem acesso continua sendo bloqueado', () {
      final dados = {'acessoCliente': true, 'acessoColaborador': false};
      expect(temAcesso(dados, 'colaborador'), isFalse);
    });

    test('REG-006: conta antiga sem campos de acesso continua funcionando (retrocompatibilidade)', () {
      // Bug anterior: NullPointerException quando campos não existem
      final dados = <String, dynamic>{'nome': 'Usuário legado', 'email': 'legado@email.com'};
      expect(temAcesso(dados, 'cliente'), isTrue);
      expect(temAcesso(dados, 'colaborador'), isTrue);
    });
  });

  // ── REG-007 a REG-010 | Regressão de Status ───────────────────────────────
  // Cenário: novos status foram adicionados; garantir que mapeamentos antigos
  // não foram alterados.
  group('REG-007 a REG-010 | Regressão — Mapeamento de status (rotuloStatus)', () {
    test('REG-007: todos os status originais mantêm seus rótulos corretos', () {
      final esperado = {
        'visivel': 'Aguardando',
        'aceito': 'Pendente',
        'em_andamento': 'Em andamento',
        'concluido': 'Concluído',
        'recusado': 'Recusada',
        'cancelada': 'Cancelada',
      };
      esperado.forEach((status, rotulo) {
        expect(rotuloStatus(status), equals(rotulo),
            reason: 'Status "$status" deveria retornar "$rotulo"');
      });
    });

    test('REG-008: podeEditar() continua permitindo edição apenas para "visivel"', () {
      // Bug anterior: após adicionar status "rascunho", a condição foi alterada
      // e passou a permitir edição para "aceito" também
      expect(podeEditar('visivel'), isTrue);
      for (final s in ['aceito', 'em_andamento', 'concluido', 'recusado', 'cancelada']) {
        expect(podeEditar(s), isFalse, reason: 'Status "$s" NÃO deveria ser editável');
      }
    });

    test('REG-009: acaoColaborador() mantém fluxo correto após mudanças', () {
      expect(acaoColaborador('pendente'), equals('iniciar'));
      expect(acaoColaborador('em_andamento'), equals('finalizar'));
      expect(acaoColaborador('concluido'), equals('concluido'));
    });

    test('REG-010: status desconhecido retorna o próprio valor (não lança exceção)', () {
      // Garante que novos status não quebram a aplicação
      expect(rotuloStatus('novo_status_futuro'), equals('novo_status_futuro'));
      expect(rotuloStatus(''), equals(''));
    });
  });

  // ── REG-011 a REG-014 | Regressão de Filtros ──────────────────────────────
  // Cenário: nova aba de filtro foi adicionada; garantir que filtros existentes
  // continuam funcionando corretamente.
  group('REG-011 a REG-014 | Regressão — Filtros de lista (passaNoFiltro)', () {
    const uid = 'uid_colaborador_1';

    test('REG-011: filtro "Novas" continua excluindo propostas recusadas pelo colaborador', () {
      final dados = {'status': 'visivel', 'recusadoPor': [uid]};
      expect(passaNoFiltro(dados, uid, 'Novas'), isFalse);
    });

    test('REG-012: filtro "Respondidas" continua incluindo propostas aceitas pelo próprio colaborador', () {
      final dados = {
        'status': 'aceito',
        'colaboradorId': uid,
        'recusadoPor': <String>[],
      };
      expect(passaNoFiltro(dados, uid, 'Respondidas'), isTrue);
    });

    test('REG-013: filtro "Pendentes" continua aceitando status "aceito" e "pendente"', () {
      expect(passaNoFiltro({'status': 'aceito'}, uid, 'Pendentes'), isTrue);
      expect(passaNoFiltro({'status': 'pendente'}, uid, 'Pendentes'), isTrue);
      expect(passaNoFiltro({'status': 'em_andamento'}, uid, 'Pendentes'), isFalse);
    });

    test('REG-014: filtro "Todas" continua retornando true para qualquer status', () {
      for (final s in ['visivel', 'aceito', 'pendente', 'em_andamento', 'concluido', 'cancelada', 'recusado']) {
        expect(passaNoFiltro({'status': s}, uid, 'Todas'), isTrue,
            reason: 'Filtro "Todas" deveria incluir status "$s"');
      }
    });
  });

  // ── REG-015 a REG-016 | Regressão de Casos Extremos ───────────────────────
  // Cenário: garantir que edge cases tratados anteriormente não regridem.
  group('REG-015 a REG-016 | Regressão — Casos extremos (edge cases)', () {
    test('REG-015: euRecusei() com dados vazios ou nulos não lança exceção', () {
      expect(euRecusei(<String, dynamic>{}, 'uid1'), isFalse);
      expect(euRecusei({'recusadoPor': null}, 'uid1'), isFalse);
      expect(euRecusei({'recusadoPor': ['uid1']}, null), isFalse);
    });

    test('REG-016: passaNoFiltro() com status vazio/ausente não lança exceção', () {
      expect(passaNoFiltro(<String, dynamic>{}, 'uid1', 'Novas'), isFalse);
      expect(passaNoFiltro({'status': ''}, 'uid1', 'Pendentes'), isFalse);
      // "Todas" sempre retorna true, mesmo com dados incompletos
      expect(passaNoFiltro(<String, dynamic>{}, 'uid1', 'Todas'), isTrue);
    });
  });
}
