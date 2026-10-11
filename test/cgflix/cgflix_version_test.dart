import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:plezy/cgflix/cgflix_version.dart';

void main() {
  test('Sobre mostra "Versão 1.6.1" abaixo do nome', () {
    expect(cgflixVersionLabel('1.6.1'), 'Versão 1.6.1');
    expect(cgflixVersionLabel(''), '');
  });

  test('pubspec: versão 1.6.1 (refino 2b) com versionCode 810 (a 1.6.0 usou o 800)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*([0-9.]+)\+(\d+)\s*$', multiLine: true).firstMatch(pubspec);
    expect(match, isNotNull);
    expect(match!.group(1), '1.6.1');
    expect(int.parse(match.group(2)!), 810); // instala por cima da 1.6.0 (800)
  });
}
