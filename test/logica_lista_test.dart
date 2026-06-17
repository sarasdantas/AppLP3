import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'logica_lista_test.mocks.dart';

abstract class PropostaDoc {
  Map<String, dynamic> data();
  String get id;
}

// Repositório de propostas (esconde o Firestore)
abstract class PropostaRepository {
  Future<List<PropostaDoc>> listarPropostas();
}

// ─Classe sob teste
class ListaService {
  final PropostaRepository repo;
  ListaService(this.repo);

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

  // Busca propostas no repo e devolve apenas as que passam no filtro.
  Future<List<PropostaDoc>> filtrar(String? uid, String label) async {
    final docs = await repo.listarPropostas();
    return docs.where((d) => passaNoFiltro(d.data(), uid, label)).toList();
  }
}

@GenerateMocks([PropostaRepository, PropostaDoc])
void main() {
  const uid1 = 'uid_colaborador_1';
  const uid2 = 'uid_colaborador_2';

  late MockPropostaRepository mockRepo;
  late ListaService service;

  setUp(() {
    mockRepo = MockPropostaRepository();
    service = ListaService(mockRepo);
  });

  // euRecusei()
  group('UT-009 a UT-010 | euRecusei()', () {
    test('UT-009: uid presente em recusadoPor retorna true', () {
      expect(service.euRecusei({'recusadoPor': [uid1, uid2]}, uid1), isTrue);
    });
    test('UT-010: uid ausente em recusadoPor retorna false', () {
      expect(service.euRecusei({'recusadoPor': [uid2]}, uid1), isFalse);
    });
    test('UT-010b: recusadoPor nulo retorna false', () {
      expect(service.euRecusei(<String, dynamic>{}, uid1), isFalse);
    });
    test('UT-010c: uid nulo retorna false', () {
      expect(service.euRecusei({'recusadoPor': [uid1]}, null), isFalse);
    });
  });

  // Filtros (lógica pura)
  group('UT-011 a UT-014 | passaNoFiltro()', () {
    test('UT-011: visivel e não recusou => "Novas"', () {
      expect(
          service.passaNoFiltro(
              {'status': 'visivel', 'recusadoPor': <String>[]}, uid1, 'Novas'),
          isTrue);
    });
    test('UT-012: visivel mas recusou => NÃO aparece em "Novas"', () {
      expect(
          service.passaNoFiltro(
              {'status': 'visivel', 'recusadoPor': [uid1]}, uid1, 'Novas'),
          isFalse);
    });
    test('UT-013: aceito aparece em "Pendentes"', () {
      expect(
          service.passaNoFiltro({'status': 'aceito'}, uid1, 'Pendentes'), isTrue);
    });
    test('UT-014: concluido aparece em "Concluídas"', () {
      expect(service.passaNoFiltro({'status': 'concluido'}, uid1, 'Concluídas'),
          isTrue);
    });
  });

  // Filtragem ponta-a-ponta com MOCKITO 
  group('filtrar() — repo mockado devolvendo PropostaDoc mockados', () {
    test('Retorna apenas propostas "visivel" no filtro "Novas"', () async {
      // Arrange: cria 3 docs mockados
      final doc1 = MockPropostaDoc();
      final doc2 = MockPropostaDoc();
      final doc3 = MockPropostaDoc();
      when(doc1.data())
          .thenReturn({'status': 'visivel', 'recusadoPor': <String>[]});
      when(doc2.data())
          .thenReturn({'status': 'aceito', 'colaboradorId': uid2});
      when(doc3.data())
          .thenReturn({'status': 'visivel', 'recusadoPor': [uid1]});

      when(mockRepo.listarPropostas())
          .thenAnswer((_) async => [doc1, doc2, doc3]);

      // Act
      final resultado = await service.filtrar(uid1, 'Novas');

      // Assert
      expect(resultado, hasLength(1));
      expect(resultado.first, same(doc1));
      verify(mockRepo.listarPropostas()).called(1);
    });

    test('Filtro "Respondidas" inclui aceitas pelo próprio uid', () async {
      final doc1 = MockPropostaDoc();
      final doc2 = MockPropostaDoc();
      when(doc1.data()).thenReturn(
          {'status': 'aceito', 'colaboradorId': uid1, 'recusadoPor': []});
      when(doc2.data()).thenReturn(
          {'status': 'aceito', 'colaboradorId': uid2, 'recusadoPor': []});

      when(mockRepo.listarPropostas())
          .thenAnswer((_) async => [doc1, doc2]);

      final resultado = await service.filtrar(uid1, 'Respondidas');

      expect(resultado, hasLength(1));
      expect(resultado.first, same(doc1));
    });

    test('Repo vazio => lista vazia (sem chamadas extras)', () async {
      when(mockRepo.listarPropostas()).thenAnswer((_) async => []);

      final resultado = await service.filtrar(uid1, 'Todas');

      expect(resultado, isEmpty);
      verify(mockRepo.listarPropostas()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });
  });
}
