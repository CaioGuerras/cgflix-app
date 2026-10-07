import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:plezy/cgflix/cgflix_version.dart';

void main() {
  test('Sobre mostra "CGFLIX 1.0.0"', () {
    expect(cgflixVersionLabel('1.0.0'), 'CGFLIX 1.0.0');
    expect(cgflixVersionLabel(''), 'CGFLIX');
  });

  test('pubspec: versão 1.1.0 (Etapa 1C) com versionCode maior que o da 1B (200)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*([0-9.]+)\+(\d+)\s*$', multiLine: true).firstMatch(pubspec);
    expect(match, isNotNull);
    expect(match!.group(1), '1.1.0');
    expect(int.parse(match.group(2)!), greaterThan(200)); // a Play já tem o 200 da Etapa 1B
  });
}
