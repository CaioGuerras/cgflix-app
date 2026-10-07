// Barra inferior do CGFLIX no celular: Início · Buscar · Baixados · Você.
// As bibliotecas saem da barra (viram os chips Filmes/Séries/Animes da Início) e
// "Configurações" vira "Você". TV e computador continuam com a navegação do upstream.
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../navigation/navigation_tabs.dart';
import '../utils/platform_detector.dart';

String _youLabel() => 'Você';

/// A aba "Você" ocupa o lugar das Configurações (mesmo id, outro ícone e nome).
const cgflixYouTab = NavigationTab(
  id: NavigationTabId.settings,
  onlineOnly: false,
  icon: Symbols.account_circle_rounded,
  getLabel: _youLabel,
);

/// Ordem fixa da barra do celular.
const cgflixMobileTabOrder = [
  NavigationTabId.discover,
  NavigationTabId.search,
  NavigationTabId.downloads,
  NavigationTabId.settings,
];

/// Filtra e ordena as abas visíveis para a barra do celular. Sem conexão sobram
/// Baixados e Você (o upstream já tira as abas que exigem servidor).
List<NavigationTab> cgflixMobileTabs(List<NavigationTab> visibleTabs) {
  final byId = {for (final tab in visibleTabs) tab.id: tab};
  return [
    for (final id in cgflixMobileTabOrder)
      if (id == NavigationTabId.settings) cgflixYouTab else if (byId[id] != null) byId[id]!,
  ];
}

/// A aba de Configurações vira "Você" só no celular (TV e computador ficam como no upstream).
bool cgflixUseYouTab(BuildContext context) => PlatformDetector.isMobile(context);
