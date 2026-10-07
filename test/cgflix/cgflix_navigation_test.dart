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
}
