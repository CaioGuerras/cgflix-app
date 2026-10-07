import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plezy/cgflix/cgflix_navigation.dart';
import 'package:plezy/navigation/navigation_tabs.dart';

List<NavigationTabId> _ids(List<NavigationTab> tabs) => [for (final tab in tabs) tab.id];

void main() {
  test('celular: Início · Buscar · Baixados · Você, nesta ordem', () {
    final tabs = cgflixMobileTabs(allNavigationTabs);
    expect(_ids(tabs), [
      NavigationTabId.discover,
      NavigationTabId.search,
      NavigationTabId.downloads,
      NavigationTabId.settings,
    ]);
    expect(tabs.last.getLabel(), 'Você');
  });

  test('sem conexão sobram Baixados e Você', () {
    final offline = NavigationTab.getVisibleTabs(isOffline: true);
    expect(_ids(cgflixMobileTabs(offline)), [NavigationTabId.downloads, NavigationTabId.settings]);
  });

  test('bibliotecas, TV ao vivo e Explorar saem da barra do celular', () {
    final visible = NavigationTab.getVisibleTabs(isOffline: false, hasLiveTv: true, hasExplore: true);
    final ids = _ids(cgflixMobileTabs(visible));
    expect(ids, isNot(contains(NavigationTabId.libraries)));
    expect(ids, isNot(contains(NavigationTabId.liveTv)));
    expect(ids, isNot(contains(NavigationTabId.explore)));
  });

  testWidgets('barra compacta: só ícones, mas o leitor de tela lê o nome', (tester) async {
    final semantics = tester.ensureSemantics();
    final tabs = cgflixMobileTabs(allNavigationTabs);
    NavigationTabId? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CgflixNavigationBar(
            tabs: tabs,
            currentTab: NavigationTabId.discover,
            onSelectTab: (id) => tapped = id,
          ),
        ),
      ),
    );
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.labelBehavior, NavigationDestinationLabelBehavior.alwaysHide);
    expect(bar.height, inInclusiveRange(56, 64));
    // Os nomes (Início, Buscar... no idioma do app) continuam para o TalkBack e na dica.
    for (final tab in tabs) {
      expect(find.bySemanticsLabel(RegExp(RegExp.escape(tab.getLabel()))), findsWidgets);
    }

    await tester.tap(find.byTooltip(tabs[1].getLabel()));
    await tester.pumpAndSettle();
    expect(tapped, NavigationTabId.search);
    semantics.dispose();
  });
}
