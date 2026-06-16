// ============================================================
//  test/logica_status_test.dart
//  Testes Unitários — Casa Limpa
//  TPS 3: Testes Unitários, Integração e Regressão
//  Fatec Rio Preto — GQS — Prof. Fábio T. Onishi — 2026
//
//  Execução: dart test test/logica_status_test.dart
// ============================================================

import 'package:test/test.dart';

// ── Funções extraídas de cliente_detalhes_servico.dart / editar_faxina.dart ──

/// Retorna o rótulo legível para cada status interno.
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

/// Verifica se a proposta pode ser editada com base no status atual.
bool podeEditar(String statusAtual) => statusAtual == 'visivel';

/// Verifica se os botões de ação do colaborador devem ser exibidos.
/// Retorna a ação disponível: 'iniciar', 'finalizar' ou 'concluido'.
String acaoColaborador(String status) {
  if (status == 'pendente') return 'iniciar';
  if (status == 'em_andamento') return 'finalizar';
  return 'concluido';
}

// ── Testes ────────────────────────────────────────────────────────────────────
void main() {
  // ── rotuloStatus() ─────────────────────────────────────────────────────────
  group('UT-015 a UT-018 | rotuloStatus()', () {
    test('UT-015: visivel => Aguardando', () {
      expect(rotuloStatus('visivel'), equals('Aguardando'));
    });

    test('UT-016: aceito => Pendente', () {
      expect(rotuloStatus('aceito'), equals('Pendente'));
    });

    test('UT-017: em_andamento => Em andamento', () {
      expect(rotuloStatus('em_andamento'), equals('Em andamento'));
    });

    test('UT-018: concluido => Concluído', () {
      expect(rotuloStatus('concluido'), equals('Concluído'));
    });

    test('recusado => Recusada', () {
      expect(rotuloStatus('recusado'), equals('Recusada'));
    });

    test('cancelada => Cancelada', () {
      expect(rotuloStatus('cancelada'), equals('Cancelada'));
    });

    test('status desconhecido => retorna o próprio valor', () {
      expect(rotuloStatus('outro_status'), equals('outro_status'));
    });
  });

  // ── podeEditar() ───────────────────────────────────────────────────────────
  group('UT-019 a UT-020 | podeEditar()', () {
    test('UT-019: status aceito bloqueia edição', () {
      expect(podeEditar('aceito'), isFalse);
    });

    test('UT-019b: status em_andamento bloqueia edição', () {
      expect(podeEditar('em_andamento'), isFalse);
    });

    test('UT-019c: status concluido bloqueia edição', () {
      expect(podeEditar('concluido'), isFalse);
    });

    test('UT-019d: status cancelada bloqueia edição', () {
      expect(podeEditar('cancelada'), isFalse);
    });

    test('UT-020: status visivel permite edição', () {
      expect(podeEditar('visivel'), isTrue);
    });
  });

  // ── acaoColaborador() ──────────────────────────────────────────────────────
  group('Ação disponível para colaborador conforme status', () {
    test('status pendente => ação é iniciar', () {
      expect(acaoColaborador('pendente'), equals('iniciar'));
    });

    test('status em_andamento => ação é finalizar', () {
      expect(acaoColaborador('em_andamento'), equals('finalizar'));
    });

    test('status concluido => ação é concluido (botão desabilitado)', () {
      expect(acaoColaborador('concluido'), equals('concluido'));
    });

    test('qualquer outro status => ação padrão é concluido', () {
      expect(acaoColaborador('outro'), equals('concluido'));
    });
  });

  // ── Teste de Regressão: lógica de acesso (login.dart) ─────────────────────
  group('Regressão — _temAcesso() (lógica simulada)', () {
    /// Simula o retorno do Firestore e a lógica de _temAcesso()
    bool temAcesso(Map<String, dynamic>? dados, String tipoUsuario) {
      if (dados == null) return true;

      final acessoCliente = dados['acessoCliente'] == true;
      final acessoColaborador = dados['acessoColaborador'] == true;

      if (acessoCliente || acessoColaborador) {
        return tipoUsuario == 'cliente' ? acessoCliente : acessoColaborador;
      }
      return true; // conta antiga sem campos: não bloqueia
    }

    test('conta de cliente acessando como cliente => permitido', () {
      final dados = {'acessoCliente': true, 'acessoColaborador': false};
      expect(temAcesso(dados, 'cliente'), isTrue);
    });

    test('conta de cliente tentando acessar como colaborador => bloqueado', () {
      final dados = {'acessoCliente': true, 'acessoColaborador': false};
      expect(temAcesso(dados, 'colaborador'), isFalse);
    });

    test('conta de colaborador acessando como colaborador => permitido', () {
      final dados = {'acessoCliente': false, 'acessoColaborador': true};
      expect(temAcesso(dados, 'colaborador'), isTrue);
    });

    test('conta de colaborador tentando acessar como cliente => bloqueado', () {
      final dados = {'acessoCliente': false, 'acessoColaborador': true};
      expect(temAcesso(dados, 'cliente'), isFalse);
    });

    test('dados nulos (documento não existe) => não bloqueia', () {
      expect(temAcesso(null, 'cliente'), isTrue);
    });

    test('conta antiga sem campos de acesso => não bloqueia', () {
      final dados = <String, dynamic>{'nome': 'Usuário antigo'};
      expect(temAcesso(dados, 'cliente'), isTrue);
    });
  });
}
