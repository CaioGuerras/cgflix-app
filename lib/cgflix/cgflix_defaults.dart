// Padrões do CGFLIX. Fica neste arquivo isolado para manter a diferença em
// relação ao upstream (Plezy) mínima: os arquivos originais só chamam daqui.
import 'dart:ui' show Locale;

import '../i18n/app_locale_utils.dart';
import '../i18n/strings.g.dart';

/// Idioma padrão: PT-BR. Se o aparelho está em outro idioma que o app traduz,
/// respeita o aparelho; se o idioma não é traduzido (cairia em inglês), usa português.
AppLocale cgflixResolveDefaultLocale(Iterable<Locale> deviceLocales) {
  final resolved = resolvePreferredAppLocale(deviceLocales);
  final deviceIsEnglish = deviceLocales.any((l) => l.languageCode == 'en');
  if (resolved == AppLocale.en && !deviceIsEnglish) return AppLocale.pt;
  return resolved;
}
