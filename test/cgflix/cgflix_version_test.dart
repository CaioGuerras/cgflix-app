import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:plezy/cgflix/cgflix_version.dart';

void main() {
  test('Sobre mostra "Versão 1.6.0" abaixo do nome', () {
    expect(cgflixVersionLabel('1.6.0'), 'Versão 1.6.0');
    expect(cgflixVersionLabel(''), '');
  });

  test('pubspec: versão 1.6.0 (refino 2) com versionCode 800 (o refino 1 usou o 700)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*([0-9.]+)\+(\d+)\s*$', multiLine: true).firstMatch(pubspec);
    expect(match, isNotNull);
    expect(match!.group(1), '1.6.0');
    expect(int.parse(match.group(2)!), 800); // a Play já tem o 700 do refino 1
  });
}
