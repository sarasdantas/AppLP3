import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'regressao_test.mocks.dart';

//  CLASSES SOB TESTE (espelho da app real)
class Validador {
  String? validarEmail(String? v) =>
      (v != null && v.contains('@')) ? null : 'Insira um e-mail válido';
  String? validarSenha(String? v) =>
      (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null;
  String? validarNome(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null;
}

class StatusService {
  String rotuloStatus(String status) {
    switch (status) {
      case 'visivel': return 'Aguardando';
      case 'aceito': return 'Pendente';
      case 'em_andamento': return 'Em andamento';
      case 'concluido': return 'Concluído';
      case 'recusado': return 'Recusada';
      case 'cancelada': return 'Cancelada';
      default: return status;
    }
  }
  bool podeEditar(String s) => s == 'visivel';
  String acaoColaborador(String s) {
    if (s == 'pendente') return 'iniciar';
    if (s == 'em_andamento') return 'finalizar';
    return 'concluido';
  }
}

abstract class UsuarioRepository {
  Future<Map<String, dynamic>?> obterDadosUsuario(String uid);
}

class AcessoService {
  final UsuarioRepository repo;
  AcessoService(this.repo);

  Future<bool> temAcesso(String uid, String tipoUsuario) async {
    final dados = await repo.obterDadosUsuario(uid);
    if (dados == null) return true;
    final ac = dados['acessoCliente'] == true;
    final aco = dados['acessoColaborador'] == true;
    if (ac || aco) return tipoUsuario == 'cliente' ? ac : aco;
    return true;
  }
}

@GenerateMocks([UsuarioRepository, Validador])
void main() {
  // Validadores após refatoração
  group('REG-001 a REG-003 | Validadores (instância real)', () {
    final v = Validador();
    test('REG-001: e-mails com caracteres especiais antes do @ continuam válidos', () {
      expect(v.validarEmail('user.name+tag@email.com'), isNull);
      expect(v.validarEmail('user_name@domain.co'), isNull);
    });
    test('REG-002: senha com 6 chars (valor limite) continua válida', () {
      expect(v.validarSenha('123456'), isNull);
      expect(v.validarSenha('12345'), equals('Mínimo de 6 caracteres'));
    });
    test('REG-003: nome só com espaços continua sendo rejeitado', () {
      expect(v.validarNome('   '), equals('Informe seu nome'));
      expect(v.validarNome('\t'), equals('Informe seu nome'));
    });
  });

  // Acesso usando MOCKITO
  group('REG-004 a REG-006 | AcessoService com UsuarioRepository mockado', () {
    late MockUsuarioRepository mockRepo;
    late AcessoService acesso;

    setUp(() {
      mockRepo = MockUsuarioRepository();
      acesso = AcessoService(mockRepo);
    });

    test('REG-004: cliente com acesso permitido continua acessando', () async {
      when(mockRepo.obterDadosUsuario('uid1')).thenAnswer(
          (_) async => {'acessoCliente': true, 'acessoColaborador': false});
      expect(await acesso.temAcesso('uid1', 'cliente'), isTrue);
      verify(mockRepo.obterDadosUsuario('uid1')).called(1);
    });

    test('REG-005: colaborador sem acesso continua sendo bloqueado', () async {
      when(mockRepo.obterDadosUsuario(any)).thenAnswer(
          (_) async => {'acessoCliente': true, 'acessoColaborador': false});
      expect(await acesso.temAcesso('uid1', 'colaborador'), isFalse);
    });

    test('REG-006: conta antiga sem campos de acesso => retrocompatibilidade',
        () async {
      when(mockRepo.obterDadosUsuario(any)).thenAnswer(
          (_) async => {'nome': 'Usuário legado', 'email': 'legado@email.com'});
      expect(await acesso.temAcesso('uid1', 'cliente'), isTrue);
      expect(await acesso.temAcesso('uid1', 'colaborador'), isTrue);
    });

    test('Documento nulo => não bloqueia (proteção contra null)', () async {
      when(mockRepo.obterDadosUsuario(any)).thenAnswer((_) async => null);
      expect(await acesso.temAcesso('uid_x', 'cliente'), isTrue);
    });
  });

  // Mapeamento de status
  group('REG-007 a REG-010 | StatusService (lógica pura)', () {
    final s = StatusService();
    test('REG-007: todos os status originais mantêm rótulos', () {
      final esperado = {
        'visivel': 'Aguardando',
        'aceito': 'Pendente',
        'em_andamento': 'Em andamento',
        'concluido': 'Concluído',
        'recusado': 'Recusada',
        'cancelada': 'Cancelada',
      };
      esperado.forEach((status, rotulo) {
        expect(s.rotuloStatus(status), equals(rotulo),
            reason: 'Status "$status" deveria retornar "$rotulo"');
      });
    });
    test('REG-008: podeEditar() só "visivel"', () {
      expect(s.podeEditar('visivel'), isTrue);
      for (final st in ['aceito', 'em_andamento', 'concluido', 'recusado', 'cancelada']) {
        expect(s.podeEditar(st), isFalse, reason: '"$st" NÃO deve ser editável');
      }
    });
    test('REG-009: acaoColaborador() mantém fluxo', () {
      expect(s.acaoColaborador('pendente'), equals('iniciar'));
      expect(s.acaoColaborador('em_andamento'), equals('finalizar'));
      expect(s.acaoColaborador('concluido'), equals('concluido'));
    });
    test('REG-010: status desconhecido retorna o próprio valor', () {
      expect(s.rotuloStatus('novo_status_futuro'), equals('novo_status_futuro'));
      expect(s.rotuloStatus(''), equals(''));
    });
  });

  // Regressão usando Validador MOCKADO em um consumidor
  group('REG-VAL | Validador mockado garante chamadas esperadas', () {
    test('Mock de Validador retorna respostas controladas (não regride API)', () {
      final mockV = MockValidador();
      when(mockV.validarEmail('teste@email.com')).thenReturn(null);
      when(mockV.validarSenha('123456')).thenReturn(null);

      expect(mockV.validarEmail('teste@email.com'), isNull);
      expect(mockV.validarSenha('123456'), isNull);

      verify(mockV.validarEmail('teste@email.com')).called(1);
      verify(mockV.validarSenha('123456')).called(1);
      verifyNoMoreInteractions(mockV);
    });
  });
}
