// Etapa 1D: "Pedir" na busca sem resultado cabe deitado e com fonte grande (antes estourava).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plezy/cgflix/cgflix_navigation.dart';
import 'package:plezy/cgflix/search/cgflix_search_extras.dart';
import 'package:plezy/screens/libraries/state_messages.dart';

void main() {
  for (final (name, size, scale) in [
    ('em pé', const Size(412, 914), 1.0),
    ('deitado', const Size(914, 412), 1.0),
    ('deitado, teclado aberto, fonte 200%', const Size(914, 180), 2.0),
  ]) {
    testWidgets('sem resultado $name: sem overflow e com o botão de pedir', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      CgflixPages.requests = (_) => const Scaffold(body: Text('página Pedir'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: CgflixRequestPrompt(
                    enabled: true,
                    query: 'Duna',
                    child: const StateMessageWidget(message: 'Nada encontrado', icon: Icons.search_off),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Sem Seerr conectado: o botão leva a conectar os Pedidos.
      final button = find.text('Conectar os Pedidos');
      await tester.scrollUntilVisible(button, 100, scrollable: find.byType(Scrollable).last);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('página Pedir'), findsOneWidget);
    });
  }
}
