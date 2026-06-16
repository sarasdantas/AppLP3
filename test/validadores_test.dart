// ============================================================
//  test/validadores_test.dart
//  Testes Unitários — Casa Limpa
//  TPS 3: Testes Unitários, Integração e Regressão
//  Fatec Rio Preto — GQS — Prof. Fábio T. Onishi — 2026
//
//  Execução: dart test test/validadores_test.dart
// ============================================================

import 'package:test/test.dart';

// ── Funções de validação extraídas das telas (login.dart / registro.dart) ────
// Em um projeto real, extraia-as para lib/utils/validadores.dart e importe.

String? validarEmail(String? v) =>
    (v != null && v.contains('@')) ? null : 'Insira um e-mail válido';

String? validarSenha(String? v) =>
    (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null;

String? validarConfirmarSenha(String? v, String senha) =>
    (v != senha) ? 'As senhas não conferem' : null;

String? validarNome(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null;

// ── Testes ────────────────────────────────────────────────────────────────────
void main() {
  group('UT-001 a UT-002 | Validação de E-mail', () {
    test('UT-001: e-mail com @ é válido (retorna null)', () {
      expect(validarEmail('user@email.com'), isNull);
    });

    test('UT-002: e-mail sem @ é inválido (retorna mensagem de erro)', () {
      expect(validarEmail('useremail.com'), equals('Insira um e-mail válido'));
    });

    test('UT-002b: e-mail nulo é inválido', () {
      expect(validarEmail(null), equals('Insira um e-mail válido'));
    });

    test('UT-002c: e-mail vazio é inválido', () {
      expect(validarEmail(''), equals('Insira um e-mail válido'));
    });
  });

  group('UT-003 a UT-004 | Validação de Senha (Análise de Valor Limite)', () {
    test('UT-003: senha com 6 chars (valor limite inferior) é válida', () {
      expect(validarSenha('abc123'), isNull);
    });

    test('UT-003b: senha com mais de 6 chars é válida', () {
      expect(validarSenha('senha_segura_123'), isNull);
    });

    test('UT-004: senha com 5 chars (abaixo do limite) é inválida', () {
      expect(validarSenha('abc12'), equals('Mínimo de 6 caracteres'));
    });

    test('UT-004b: senha vazia é inválida', () {
      expect(validarSenha(''), equals('Mínimo de 6 caracteres'));
    });

    test('UT-004c: senha nula é inválida', () {
      expect(validarSenha(null), equals('Mínimo de 6 caracteres'));
    });
  });

  group('UT-005 a UT-006 | Confirmação de Senha', () {
    test('UT-005: senhas iguais retornam null', () {
      expect(validarConfirmarSenha('abc123', 'abc123'), isNull);
    });

    test('UT-006: senhas diferentes retornam mensagem de erro', () {
      expect(
        validarConfirmarSenha('xyz999', 'abc123'),
        equals('As senhas não conferem'),
      );
    });
  });

  group('UT-007 a UT-008 | Validação de Nome', () {
    test('UT-007: nome vazio retorna mensagem de erro', () {
      expect(validarNome(''), equals('Informe seu nome'));
    });

    test('UT-007b: nome com apenas espaços retorna mensagem de erro', () {
      expect(validarNome('   '), equals('Informe seu nome'));
    });

    test('UT-007c: nome nulo retorna mensagem de erro', () {
      expect(validarNome(null), equals('Informe seu nome'));
    });

    test('UT-008: nome preenchido retorna null', () {
      expect(validarNome('João Silva'), isNull);
    });
  });
}
