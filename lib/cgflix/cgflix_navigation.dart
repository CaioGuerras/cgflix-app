// Barra inferior do CGFLIX no celular: Início · Buscar · Baixados · Você.
// As bibliotecas saem da barra (viram os chips Filmes/Séries/Animes da Início) e
// "Configurações" vira "Você". TV e computador continuam com a navegação do upstream.
// Etapa 1C: barra compacta só com ícones (o nome fica no leitor de tela e na dica),
// translúcida com desfoque sobre o conteúdo, indicador roxo no ícone ativo.
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../navigation/navigation_tabs.dart';
import '../utils/platform_detector.dart';
import '../widgets/app_icon.dart';
import 'cgflix_style.dart';

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

/// Altura da barra compacta (sem contar a barra de gestos do sistema).
const cgflixNavBarHeight = 60.0;

/// Barra do celular: só ícones, sem rótulos ([NavigationDestinationLabelBehavior.alwaysHide]);
/// o TalkBack continua lendo "Início", "Buscar"... e segurar mostra o nome.
class CgflixNavigationBar extends StatelessWidget {
  const CgflixNavigationBar({super.key, required this.tabs, required this.currentTab, required this.onSelectTab});
  final List<NavigationTab> tabs;
  final NavigationTabId currentTab;
  final ValueChanged<NavigationTabId> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = tabs.indexWhere((tab) => tab.id == currentTab);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: CgflixColors.background.withValues(alpha: 0.78),
            border: const Border(top: BorderSide(color: Color(0x14FFFFFF), width: 0.5)),
          ),
          child: NavigationBar(
            height: cgflixNavBarHeight,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            indicatorColor: CgflixColors.accent.withValues(alpha: 0.22),
            indicatorShape: const StadiumBorder(),
            animationDuration: CgflixMotion.fast,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            onDestinationSelected: (index) {
              if (index < 0 || index >= tabs.length) return;
              if (index != selectedIndex) HapticFeedback.selectionClick();
              onSelectTab(tabs[index].id);
            },
            destinations: [
              for (final tab in tabs)
                NavigationDestination(
                  icon: AppIcon(tab.icon, fill: 0, color: Colors.white70, size: 26),
                  // Ícone cheio quando ativo, contornado quando não.
                  selectedIcon: AppIcon(tab.icon, fill: 1, color: CgflixColors.accent, size: 26),
                  label: tab.getLabel(),
                  tooltip: tab.getLabel(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Telas do upstream que não sabem que a barra fica por cima (ex.: Baixados): terminam
/// acima dela, em vez de deixar as últimas linhas escondidas atrás do vidro.
class CgflixAboveNavBar extends StatelessWidget {
  const CgflixAboveNavBar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: MediaQuery.removePadding(context: context, removeBottom: true, child: child),
    );
  }
}
