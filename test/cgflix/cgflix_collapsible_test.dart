import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plezy/cgflix/cgflix_collapsible.dart';
import 'package:plezy/cgflix/cgflix_defaults.dart';
import 'package:plezy/theme/mono_theme.dart';
import 'package:plezy/widgets/settings_section.dart';

Widget _host(Widget child) => MaterialApp(
  theme: monoTheme(dark: true),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('seções recolhíveis', () {
    testWidgets('começam fechadas e abrem ao tocar no título', (tester) async {
      await tester.pumpWidget(
        _host(
          const CgflixCollapsibleScope(
            child: SettingsGroup(
              title: 'Áudio',
              children: [ListTile(title: Text('Opção escondida'))],
            ),
          ),
        ),
      );

      expect(find.text('Áudio'), findsOneWidget);
      expect(find.text('Opção escondida'), findsNothing);

      await tester.tap(find.text('Áudio'));
      await tester.pump();
      expect(find.text('Opção escondida'), findsOneWidget);

      await tester.tap(find.text('Áudio'));
      await tester.pump();
      expect(find.text('Opção escondida'), findsNothing);
    });

    testWidgets('initiallyExpanded abre a seção de saída', (tester) async {
      await tester.pumpWidget(
        _host(
          const CgflixCollapsibleScope(
            child: SettingsGroup(
              title: 'Legendas',
              initiallyExpanded: true,
              children: [ListTile(title: Text('Visível'))],
            ),
          ),
        ),
      );
      expect(find.text('Visível'), findsOneWidget);
    });

    testWidgets('sem o escopo o grupo continua igual ao original', (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingsGroup(
            title: 'Original',
            children: [ListTile(title: Text('Sempre visível'))],
          ),
        ),
      );
      expect(find.text('Sempre visível'), findsOneWidget);
    });
  });

  test('Início sem Recarregar, Assistir juntos e Controle remoto no cabeçalho', () {
    expect(cgflixShowHomeHeaderExtras, isFalse);
  });
}
