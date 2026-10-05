// Padrões do CGFLIX. Fica neste arquivo isolado para manter a diferença em
// relação ao upstream (Plezy) mínima: os arquivos originais só chamam daqui.
import 'dart:ui' show Locale;

import '../i18n/strings.g.dart';

/// Idioma padrão: português do Brasil em qualquer aparelho (o público é brasileiro).
/// Quem quiser outro idioma troca em Configurações > Geral.
AppLocale cgflixResolveDefaultLocale(Iterable<Locale> deviceLocales) => AppLocale.pt;

/// Cabeçalho da Início: Recarregar, Assistir juntos e Controle remoto ficam
/// escondidos (Recarregar virou "puxar para atualizar"; os outros dois estão
/// em Configurações > Avançado). Mude para `true` para voltar ao original.
const bool cgflixShowHomeHeaderExtras = false;

/// As opções do mpv saem da tela de Reprodução e ficam só em Configurações > Avançado.
const bool cgflixMpvConfigOnlyInAdvanced = true;
