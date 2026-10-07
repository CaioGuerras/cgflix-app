// Tema do CGFLIX por cima do tema "mono" do upstream (Etapa 1C): fonte Inter, cores do site
// no modo OLED, transições de página de 250–350 ms com ease-out e barras do sistema
// transparentes (ponta a ponta). O upstream chama daqui com um gancho de uma linha.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cgflix_style.dart';

const cgflixFontFamily = 'Inter';

/// Troca de página no Android: entra deslizando de leve e aparecendo; a de baixo recua um
/// pouco. 300 ms para ir, 250 ms para voltar (o gesto de voltar acompanha o dedo).
class CgflixPageTransitionsBuilder extends PageTransitionsBuilder {
  const CgflixPageTransitionsBuilder();

  @override
  Duration get transitionDuration => CgflixMotion.medium;

  @override
  Duration get reverseTransitionDuration => CgflixMotion.fast;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(parent: animation, curve: CgflixMotion.curve, reverseCurve: Curves.easeInCubic);
    final under = CurvedAnimation(parent: secondaryAnimation, curve: CgflixMotion.curve);
    return SlideTransition(
      position: Tween(begin: Offset.zero, end: const Offset(-0.06, 0)).animate(under),
      child: SlideTransition(
        position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(enter),
        child: FadeTransition(opacity: enter, child: child),
      ),
    );
  }
}

/// Marca do CGFLIX sobre o tema do upstream. [oled] = tema escuro padrão do CGFLIX.
ThemeData cgflixBrandTheme(ThemeData theme, {required bool oled}) {
  final branded = theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: cgflixFontFamily),
    primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: cgflixFontFamily),
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(fontFamily: cgflixFontFamily),
      systemOverlayStyle: cgflixSystemOverlay(theme.brightness),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {...theme.pageTransitionsTheme.builders, TargetPlatform.android: const CgflixPageTransitionsBuilder()},
    ),
    progressIndicatorTheme: theme.progressIndicatorTheme.copyWith(color: CgflixColors.accent),
    textSelectionTheme: theme.textSelectionTheme.copyWith(
      cursorColor: CgflixColors.accent,
      selectionColor: CgflixColors.accent.withValues(alpha: 0.35),
      selectionHandleColor: CgflixColors.accent,
    ),
  );
  if (!oled) return branded;
  // Mesmas cores do site: preto #07060a e superfícies #120e1a.
  return branded.copyWith(
    scaffoldBackgroundColor: CgflixColors.background,
    canvasColor: CgflixColors.background,
    colorScheme: branded.colorScheme.copyWith(
      surface: CgflixColors.surface,
      surfaceContainerHighest: CgflixColors.surfaceHigh,
      surfaceContainerLow: CgflixColors.background,
      surfaceDim: CgflixColors.background,
      surfaceBright: CgflixColors.surface,
      primaryContainer: CgflixColors.surface,
      secondaryContainer: CgflixColors.surface,
      onSurfaceVariant: CgflixColors.textMuted,
    ),
    appBarTheme: branded.appBarTheme.copyWith(backgroundColor: CgflixColors.background),
    bottomSheetTheme: branded.bottomSheetTheme.copyWith(
      backgroundColor: CgflixColors.surface,
      modalBackgroundColor: CgflixColors.surface,
    ),
    dialogTheme: branded.dialogTheme.copyWith(backgroundColor: CgflixColors.surface),
  );
}

/// Barras do sistema transparentes, com ícones claros no tema escuro.
SystemUiOverlayStyle cgflixSystemOverlay(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
    statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    statusBarBrightness: dark ? Brightness.dark : Brightness.light,
    systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
  );
}

/// Ponta a ponta de verdade no Android: o app desenha atrás da barra de status e da de
/// gestos (as telas respeitam os recuos com SafeArea/MediaQuery).
void cgflixEnableEdgeToEdge() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(cgflixSystemOverlay(Brightness.dark));
}
