// ============================================================
//  test/logica_lista_test.dart
//  Testes Unitários — Casa Limpa
//  TPS 3: Testes Unitários, Integração e Regressão
//  Fatec Rio Preto — GQS — Prof. Fábio T. Onishi — 2026
//
//  Execução: dart test test/logica_lista_test.dart
// ============================================================

import 'package:test/test.dart';

// ── Funções extraídas de lista.dart ───────────────────────────────────────────
// Em um projeto real: lib/utils/logica_lista.dart

/// Verifica se o colaborador (uid) recusou a proposta.
bool euRecusei(Map<String, dynamic> dados, String? uid) {
  final lista = dados['recusadoPor'];
  return uid != null && lista is List && lista.contains(uid);
}

/// Decide se um documento passa no filtro selecionado.
/// [navIndex] 0 = Propostas, 1 = Faxinas
bool passaNoFiltro(
  Map<String, dynamic> dados,
  String? uid,
  String label,
) {
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
    default: // 'Todas'
      return true;
  }
}

// ── Testes ────────────────────────────────────────────────────────────────────
void main() {
  const uid1 = 'uid_colaborador_1';
  const uid2 = 'uid_colaborador_2';

  // ── euRecusei ──────────────────────────────────────────────────────────────
  group('UT-009 a UT-010 | euRecusei()', () {
    test('UT-009: uid presente em recusadoPor retorna true', () {
      final dados = {'recusadoPor': [uid1, uid2]};
      expect(euRecusei(dados, uid1), isTrue);
    });

    test('UT-010: uid ausente em recusadoPor retorna false', () {
      final dados = {'recusadoPor': [uid2]};
      expect(euRecusei(dados, uid1), isFalse);
    });

    test('UT-010b: recusadoPor nulo retorna false', () {
      final dados = <String, dynamic>{};
      expect(euRecusei(dados, uid1), isFalse);
    });

    test('UT-010c: uid nulo retorna false', () {
      final dados = {'recusadoPor': [uid1]};
      expect(euRecusei(dados, null), isFalse);
    });
  });

  // ── Filtro: Novas ──────────────────────────────────────────────────────────
  group('UT-011 a UT-012 | Filtro "Novas"', () {
    test('UT-011: visivel e não recusou => aparece em Novas', () {
      final dados = {'status': 'visivel', 'recusadoPor': <String>[]};
      expect(passaNoFiltro(dados, uid1, 'Novas'), isTrue);
    });

    test('UT-012: visivel mas recusou => NÃO aparece em Novas', () {
      final dados = {'status': 'visivel', 'recusadoPor': [uid1]};
      expect(passaNoFiltro(dados, uid1, 'Novas'), isFalse);
    });

    test('UT-012b: status diferente de visivel => NÃO aparece em Novas', () {
      final dados = {'status': 'aceito', 'recusadoPor': <String>[]};
      expect(passaNoFiltro(dados, uid1, 'Novas'), isFalse);
    });
  });

  // ── Filtro: Respondidas ────────────────────────────────────────────────────
  group('Filtro "Respondidas"', () {
    test('Proposta recusada pelo colaborador aparece em Respondidas', () {
      final dados = {'status': 'visivel', 'recusadoPor': [uid1]};
      expect(passaNoFiltro(dados, uid1, 'Respondidas'), isTrue);
    });

    test('Proposta aceita pelo mesmo colaborador aparece em Respondidas', () {
      final dados = {
        'status': 'aceito',
        'colaboradorId': uid1,
        'recusadoPor': <String>[],
      };
      expect(passaNoFiltro(dados, uid1, 'Respondidas'), isTrue);
    });

    test('Proposta aceita por outro colaborador NÃO aparece em Respondidas', () {
      final dados = {
        'status': 'aceito',
        'colaboradorId': uid2,
        'recusadoPor': <String>[],
      };
      expect(passaNoFiltro(dados, uid1, 'Respondidas'), isFalse);
    });
  });

  // ── Filtro: Pendentes ──────────────────────────────────────────────────────
  group('UT-013 | Filtro "Pendentes"', () {
    test('UT-013: status aceito aparece em Pendentes', () {
      expect(passaNoFiltro({'status': 'aceito'}, uid1, 'Pendentes'), isTrue);
    });

    test('status pendente aparece em Pendentes', () {
      expect(passaNoFiltro({'status': 'pendente'}, uid1, 'Pendentes'), isTrue);
    });

    test('status em_andamento NÃO aparece em Pendentes', () {
      expect(passaNoFiltro({'status': 'em_andamento'}, uid1, 'Pendentes'), isFalse);
    });
  });

  // ── Filtro: Em andamento ───────────────────────────────────────────────────
  group('Filtro "Em andamento"', () {
    test('status em_andamento aparece', () {
      expect(passaNoFiltro({'status': 'em_andamento'}, uid1, 'Em andamento'), isTrue);
    });

    test('status concluido NÃO aparece em Em andamento', () {
      expect(passaNoFiltro({'status': 'concluido'}, uid1, 'Em andamento'), isFalse);
    });
  });

  // ── Filtro: Concluídas ─────────────────────────────────────────────────────
  group('UT-014 | Filtro "Concluídas"', () {
    test('UT-014: status concluido aparece em Concluídas', () {
      expect(passaNoFiltro({'status': 'concluido'}, uid1, 'Concluídas'), isTrue);
    });

    test('status em_andamento NÃO aparece em Concluídas', () {
      expect(passaNoFiltro({'status': 'em_andamento'}, uid1, 'Concluídas'), isFalse);
    });
  });

  // ── Filtro: Todas ──────────────────────────────────────────────────────────
  group('Filtro "Todas"', () {
    for (final status in ['visivel', 'aceito', 'pendente', 'em_andamento', 'concluido', 'cancelada']) {
      test('status "$status" passa no filtro Todas', () {
        expect(passaNoFiltro({'status': status}, uid1, 'Todas'), isTrue);
      });
    }
  });
}
