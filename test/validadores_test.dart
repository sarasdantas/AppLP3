// ============================================================
//  test/validadores_test.dart
//  Testes Unitários com Mockito — Casa Limpa
//  TPS 3: Testes Unitários, Integração e Regressão
//  Fatec Rio Preto — GQS — Prof. Fábio T. Onishi — 2026
//
//  Execução:
//    1) flutter pub run build_runner build --delete-conflicting-outputs
//    2) dart test test/validadores_test.dart
// ============================================================
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'validadores_test.mocks.dart';

// ── Classe sob teste (real) ──────────────────────────────────────────────────
// Em projeto real: lib/utils/validador.dart
class Validador {
  String? validarEmail(String? v) =>
      (v != null && v.contains('@')) ? null : 'Insira um e-mail válido';
  String? validarSenha(String? v) =>
      (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null;
  String? validarConfirmarSenha(String? v, String senha) =>
      (v != senha) ? 'As senhas não conferem' : null;
  String? validarNome(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null;
}

// ── Consumidor que DEPENDE de Validador (alvo dos mocks) ─────────────────────
// Em projeto real: lib/controllers/registro_controller.dart
class RegistroController {
  final Validador validador;
  RegistroController(this.validador);

  /// Retorna null se OK, ou a primeira mensagem de erro encontrada.
  String? validarFormulario({
    required String nome,
    required String email,
    required String senha,
    required String confirmar,
  }) {
    return validador.validarNome(nome) ??
        validador.validarEmail(email) ??
        validador.validarSenha(senha) ??
        validador.validarConfirmarSenha(confirmar, senha);
  }
}

// ── Anotação para gerar os mocks ─────────────────────────────────────────────
@GenerateMocks([Validador])
void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // PARTE A — Testes da própria classe Validador (sem mock — é o SUT)
  // ──────────────────────────────────────────────────────────────────────────
  group('UT-001 a UT-008 | Validador (classe real)', () {
    late Validador validador;

    setUp(() {
      validador = Validador();
    });

    test('UT-001: e-mail com @ é válido', () {
      expect(validador.validarEmail('user@email.com'), isNull);
    });
    test('UT-002: e-mail sem @ é inválido', () {
      expect(validador.validarEmail('useremail.com'),
          equals('Insira um e-mail válido'));
    });
    test('UT-002b: e-mail nulo é inválido', () {
      expect(validador.validarEmail(null), equals('Insira um e-mail válido'));
    });
    test('UT-003: senha com 6 chars é válida', () {
      expect(validador.validarSenha('abc123'), isNull);
    });
    test('UT-004: senha com 5 chars é inválida', () {
      expect(validador.validarSenha('abc12'), equals('Mínimo de 6 caracteres'));
    });
    test('UT-005: senhas iguais retornam null', () {
      expect(validador.validarConfirmarSenha('abc123', 'abc123'), isNull);
    });
    test('UT-006: senhas diferentes retornam erro', () {
      expect(validador.validarConfirmarSenha('xyz999', 'abc123'),
          equals('As senhas não conferem'));
    });
    test('UT-007: nome vazio retorna erro', () {
      expect(validador.validarNome(''), equals('Informe seu nome'));
    });
    test('UT-008: nome preenchido retorna null', () {
      expect(validador.validarNome('João Silva'), isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // PARTE B — Testes com MOCKITO: RegistroController usa Validador MOCKADO
  // ──────────────────────────────────────────────────────────────────────────
  group('UT-MOCK | RegistroController com Validador mockado', () {
    late MockValidador mockValidador;
    late RegistroController controller;

    setUp(() {
      mockValidador = MockValidador();
      controller = RegistroController(mockValidador);
    });

    test('Quando todos os validadores retornam null, formulário é válido', () {
      // Arrange: configura o comportamento do mock
      when(mockValidador.validarNome(any)).thenReturn(null);
      when(mockValidador.validarEmail(any)).thenReturn(null);
      when(mockValidador.validarSenha(any)).thenReturn(null);
      when(mockValidador.validarConfirmarSenha(any, any)).thenReturn(null);

      // Act
      final resultado = controller.validarFormulario(
        nome: 'Maria',
        email: 'maria@email.com',
        senha: 'senha123',
        confirmar: 'senha123',
      );

      // Assert
      expect(resultado, isNull);
      verify(mockValidador.validarNome('Maria')).called(1);
      verify(mockValidador.validarEmail('maria@email.com')).called(1);
      verify(mockValidador.validarSenha('senha123')).called(1);
      verify(mockValidador.validarConfirmarSenha('senha123', 'senha123'))
          .called(1);
    });

    test('Para curto-circuito: se nome falha, demais validadores NÃO são chamados',
        () {
      when(mockValidador.validarNome(any)).thenReturn('Informe seu nome');

      final resultado = controller.validarFormulario(
        nome: '',
        email: 'maria@email.com',
        senha: 'senha123',
        confirmar: 'senha123',
      );

      expect(resultado, equals('Informe seu nome'));
      verify(mockValidador.validarNome('')).called(1);
      verifyNever(mockValidador.validarEmail(any));
      verifyNever(mockValidador.validarSenha(any));
      verifyNever(mockValidador.validarConfirmarSenha(any, any));
    });

    test('Quando email falha, senha e confirmação não são validados', () {
      when(mockValidador.validarNome(any)).thenReturn(null);
      when(mockValidador.validarEmail(any))
          .thenReturn('Insira um e-mail válido');

      final resultado = controller.validarFormulario(
        nome: 'Maria',
        email: 'invalido',
        senha: 'senha123',
        confirmar: 'senha123',
      );

      expect(resultado, equals('Insira um e-mail válido'));
      verifyNever(mockValidador.validarSenha(any));
      verifyNever(mockValidador.validarConfirmarSenha(any, any));
    });
  });
}
