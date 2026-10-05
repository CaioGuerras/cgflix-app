// Padrões do CGFLIX. Fica neste arquivo isolado para manter a diferença em
// relação ao upstream (Plezy) mínima: os arquivos originais só chamam daqui.
import 'dart:ui' show Locale;

import '../i18n/app_locale_utils.dart';
import '../i18n/strings.g.dart';

/// Servidor Jellyfin SUGERIDO (pré-preenchido e editável; não é embutido).
const String cgflixSuggestedJellyfinUrl = 'https://netflix.docaio.com.br';

/// Idioma padrão: PT-BR. Se o aparelho está em outro idioma que o app traduz,
/// respeita o aparelho; se o idioma não é traduzido (cairia em inglês), usa português.
AppLocale cgflixResolveDefaultLocale(Iterable<Locale> deviceLocales) {
  final resolved = resolvePreferredAppLocale(deviceLocales);
  final deviceIsEnglish = deviceLocales.any((l) => l.languageCode == 'en');
  if (resolved == AppLocale.en && !deviceIsEnglish) return AppLocale.pt;
  return resolved;
}
