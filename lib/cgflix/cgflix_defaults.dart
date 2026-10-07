// Padrões do CGFLIX. Fica neste arquivo isolado para manter a diferença em
// relação ao upstream (Plezy) mínima: os arquivos originais só chamam daqui.
import 'dart:ui' show Locale;

import '../i18n/app_locale_utils.dart';
import '../i18n/strings.g.dart';

/// Idioma padrão: português do Brasil. Só respeita o aparelho se ele estiver num
/// idioma traduzido que não seja inglês; inglês ou idioma sem tradução vira português.
AppLocale cgflixResolveDefaultLocale(Iterable<Locale> deviceLocales) {
  final resolved = resolvePreferredAppLocale(deviceLocales);
  return resolved == AppLocale.en ? AppLocale.pt : resolved;
}

/// Cabeçalho da Início: Recarregar, Assistir juntos e Controle remoto ficam
/// escondidos (Recarregar virou "puxar para atualizar"; os outros dois estão
/// em Configurações > Avançado). Mude para `true` para voltar ao original.
const bool cgflixShowHomeHeaderExtras = false;

/// As opções do mpv saem da tela de Reprodução e ficam só em Configurações > Avançado.
const bool cgflixMpvConfigOnlyInAdvanced = true;

/// Busca: espera depois da última letra digitada antes de ir ao servidor.
const Duration cgflixSearchDebounce = Duration(milliseconds: 300);

/// Busca: pessoas (atores/diretores) por termo. Cada pessoa gera 1 consulta de
/// confirmação ao Jellyfin, então o teto antigo (20) atrasava os primeiros resultados.
const int cgflixSearchPeopleLimit = 5;

/// Busca: máximo de resultados por tipo e por biblioteca (antes 100).
const int cgflixSearchResultLimit = 40;

/// Busca unificada (Etapa 1C): um cartão por título/pessoa, sem nome de servidor.
/// Mude para `false` para voltar à lista do upstream (uma linha por servidor).
const bool cgflixUnifiedSearch = true;
