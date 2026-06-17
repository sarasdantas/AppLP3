import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'logica_status_test.mocks.dart';

// Abstração que esconde o Firestore
abstract class UsuarioRepository {
  // Retorna os dados do usuário ou null se não existir.
  Future<Map<String, dynamic>?> obterDadosUsuario(String uid);
}

// Classe sob teste: lógica de status + acesso, recebendo repo por injeção
class StatusService {
  final UsuarioRepository repo;
  StatusService(this.repo);

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

  // Busca os dados no repositório e decide se o usuário tem acesso.
  Future<bool> temAcesso(String uid, String tipoUsuario) async {
    final dados = await repo.obterDadosUsuario(uid);
    if (dados == null) return true;
    final acessoCliente = dados['acessoCliente'] == true;
    final acessoColaborador = dados['acessoColaborador'] == true;
    if (acessoCliente || acessoColaborador) {
      return tipoUsuario == 'cliente' ? acessoCliente : acessoColaborador;
    }
    return true;
  }
}

@GenerateMocks([UsuarioRepository])
void main() {
  late MockUsuarioRepository mockRepo;
  late StatusService service;

  setUp(() {
    mockRepo = MockUsuarioRepository();
    service = StatusService(mockRepo);
  });

  // rotuloStatus() (lógica pura)
  group('UT-015 a UT-018 | rotuloStatus()', () {
    test('UT-015: visivel => Aguardando',
        () => expect(service.rotuloStatus('visivel'), equals('Aguardando')));
    test('UT-016: aceito => Pendente',
        () => expect(service.rotuloStatus('aceito'), equals('Pendente')));
    test('UT-017: em_andamento => Em andamento',
        () => expect(
            service.rotuloStatus('em_andamento'), equals('Em andamento')));
    test('UT-018: concluido => Concluído',
        () => expect(service.rotuloStatus('concluido'), equals('Concluído')));
    test('status desconhecido => retorna o próprio valor',
        () => expect(service.rotuloStatus('outro'), equals('outro')));
  });

  // podeEditar()
  group('UT-019 a UT-020 | podeEditar()', () {
    test('UT-019: status aceito bloqueia edição',
        () => expect(service.podeEditar('aceito'), isFalse));
    test('UT-020: status visivel permite edição',
        () => expect(service.podeEditar('visivel'), isTrue));
  });

  // acaoColaborador()
  group('Ação disponível para colaborador', () {
    test('pendente => iniciar',
        () => expect(service.acaoColaborador('pendente'), equals('iniciar')));
    test('em_andamento => finalizar',
        () => expect(
            service.acaoColaborador('em_andamento'), equals('finalizar')));
    test('concluido => concluido',
        () => expect(service.acaoColaborador('concluido'), equals('concluido')));
  });

  // temAcesso() usando MOCKITO
  group('Regressão — temAcesso() com Mockito', () {
    test('cliente acessando como cliente => permitido', () async {
      when(mockRepo.obterDadosUsuario('uid_cli')).thenAnswer(
          (_) async => {'acessoCliente': true, 'acessoColaborador': false});

      final ok = await service.temAcesso('uid_cli', 'cliente');

      expect(ok, isTrue);
      verify(mockRepo.obterDadosUsuario('uid_cli')).called(1);
    });

    test('cliente tentando acessar como colaborador => bloqueado', () async {
      when(mockRepo.obterDadosUsuario(any)).thenAnswer(
          (_) async => {'acessoCliente': true, 'acessoColaborador': false});

      final ok = await service.temAcesso('uid_cli', 'colaborador');
      expect(ok, isFalse);
    });

    test('colaborador acessando como colaborador => permitido', () async {
      when(mockRepo.obterDadosUsuario(any)).thenAnswer(
          (_) async => {'acessoCliente': false, 'acessoColaborador': true});

      expect(await service.temAcesso('uid_col', 'colaborador'), isTrue);
    });

    test('dados nulos (documento não existe) => não bloqueia', () async {
      when(mockRepo.obterDadosUsuario(any)).thenAnswer((_) async => null);
      expect(await service.temAcesso('uid_x', 'cliente'), isTrue);
    });

    test('conta antiga sem campos de acesso => não bloqueia', () async {
      when(mockRepo.obterDadosUsuario(any))
          .thenAnswer((_) async => {'nome': 'Usuário antigo'});
      expect(await service.temAcesso('uid_legado', 'cliente'), isTrue);
    });
  });
}
