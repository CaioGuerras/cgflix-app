// Etapa 1D (G): dedicatória em destaque e o interruptor "Mostrar dedicatória" (Avançado).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plezy/cgflix/cgflix_about.dart';
import 'package:plezy/services/settings_service.dart';

import '../test_helpers/prefs.dart';

void main() {
  setUp(resetSharedPreferencesForTest);

  testWidgets('abertura mostra a dedicatória e "Mostrar dedicatória" esconde', (tester) async {
    final service = await SettingsService.getInstance();
    expect(service.read(cgflixShowDedicationPref), isTrue, reason: 'padrão ligado');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: CgflixIntroDedication())),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(cgflixDedicationText), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Isis e Heitor')), findsOneWidget);

    await service.write(cgflixShowDedicationPref, false);
    await tester.pump();
    expect(find.text(cgflixDedicationText), findsNothing);

    // No Sobre ela continua sempre.
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CgflixDedication())));
    expect(find.text(cgflixDedicationText), findsOneWidget);
  });
}
