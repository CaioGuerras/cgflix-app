// Regras da Início do CGFLIX ("só o nosso acervo") sem widgets, para dar para testar:
// ordem das linhas, consultas ao Jellyfin, leitura do emalta.json, chips e gêneros.
import '../../media/media_kind.dart';
import '../../media/media_library.dart';

/// As linhas da Início, nesta ordem (o destaque fica acima de todas).
enum CgflixRowKind { continueWatching, trending, releases, newEpisodes, newMovies, newShows, genre }

/// Ordem fixa das linhas fixas; as de gênero vêm depois, uma por gênero.
const cgflixFixedRowOrder = [
  CgflixRowKind.continueWatching,
  CgflixRowKind.trending,
  CgflixRowKind.releases,
  CgflixRowKind.newEpisodes,
  CgflixRowKind.newMovies,
  CgflixRowKind.newShows,
];

/// Títulos iguais aos do site.
String cgflixRowTitle(CgflixRowKind kind, {String? genre, String? trendingTitle}) => switch (kind) {
  CgflixRowKind.continueWatching => 'Continuar assistindo',
  CgflixRowKind.trending => (trendingTitle?.trim().isNotEmpty ?? false) ? trendingTitle!.trim() : cgflixTrendingTitle,
  CgflixRowKind.releases => 'Lançamentos',
  CgflixRowKind.newEpisodes => 'Novos episódios',
  CgflixRowKind.newMovies => 'Novidades em filmes',
  CgflixRowKind.newShows => 'Novidades em séries e animes',
  CgflixRowKind.genre => genre ?? '',
};

const cgflixTrendingTitle = 'Em alta no Brasil';

/// Quantos itens cada linha pede ao servidor.
const cgflixRowLimit = 20;

/// Quantos gêneros viram linhas (os com mais títulos primeiro).
const cgflixMaxGenreRows = 10;

/// Endereço do arquivo de "Em alta", relativo ao endereço do servidor.
const cgflixTrendingPath = '/cgflix/emalta.json';

/// Por quanto tempo o "Em alta" vale no aparelho.
const cgflixTrendingCacheTtl = Duration(hours: 1);

/// Troca do destaque.
const cgflixHeroInterval = Duration(seconds: 8);

/// Parâmetros de `GET /Items` para cada linha que vem de consulta direta.
/// Linhas que não são consulta (Continuar, Em alta) devolvem `null`.
Map<String, String>? cgflixRowQuery(CgflixRowKind kind, {String? genre, DateTime? now}) {
  final today = (now ?? DateTime.now()).toUtc();
  final limit = '$cgflixRowLimit';
  return switch (kind) {
    CgflixRowKind.continueWatching || CgflixRowKind.trending => null,
    // Filmes pela data de lançamento (sem os que ainda vão estrear).
    CgflixRowKind.releases => {
      'IncludeItemTypes': 'Movie',
      'SortBy': 'PremiereDate,SortName',
      'SortOrder': 'Descending,Ascending',
      'MaxPremiereDate': today.toIso8601String(),
      'Limit': limit,
    },
    // Episódios que chegaram por último (sem os "fantasmas" ainda não exibidos).
    CgflixRowKind.newEpisodes => {
      'IncludeItemTypes': 'Episode',
      'SortBy': 'DateCreated,SortName',
      'SortOrder': 'Descending,Ascending',
      'IsMissing': 'false',
      'Limit': limit,
    },
    CgflixRowKind.newMovies => {
      'IncludeItemTypes': 'Movie',
      'SortBy': 'DateCreated,SortName',
      'SortOrder': 'Descending,Ascending',
      'Limit': limit,
    },
    // Séries (e animes) pela data do último conteúdo novo.
    CgflixRowKind.newShows => {
      'IncludeItemTypes': 'Series',
      'SortBy': 'DateLastContentAdded,SortName',
      'SortOrder': 'Descending,Ascending',
      'Limit': limit,
    },
    CgflixRowKind.genre => {
      'IncludeItemTypes': 'Movie,Series',
      'Genres': genre ?? '',
      'SortBy': 'CommunityRating,SortName',
      'SortOrder': 'Descending,Ascending',
      'Limit': limit,
    },
  };
}

/// Destaque: filmes e séries com fundo e logo, sorteados pelo servidor.
Map<String, String> cgflixHeroQuery() => const {
  'IncludeItemTypes': 'Movie,Series',
  'ImageTypes': 'Backdrop,Logo',
  'SortBy': 'Random',
  'Limit': '8',
};

// ---------------------------------------------------------------------------
// Em alta no Brasil

class CgflixTrendingEntry {
  const CgflixTrendingEntry({required this.id, this.name, this.type});
  final String id;
  final String? name;
  final String? type;
}

class CgflixTrending {
  const CgflixTrending({required this.title, required this.entries});
  final String title;

  /// Já na ordem do ranking.
  final List<CgflixTrendingEntry> entries;

  List<String> get ids => [for (final e in entries) e.id];

  /// Lê `{"titulo","itens":[{"id","nome","tipo"}]}`. Tolerante: ignora itens sem id e
  /// ids repetidos; devolve `null` se não houver nenhum item aproveitável.
  static CgflixTrending? parse(Object? json) {
    if (json is! Map) return null;
    final rawItems = json['itens'];
    if (rawItems is! List) return null;
    final seen = <String>{};
    final entries = <CgflixTrendingEntry>[];
    for (final raw in rawItems) {
      if (raw is! Map) continue;
      final id = raw['id'];
      final idText = id is String ? id.trim() : (id is num ? '$id' : '');
      if (idText.isEmpty || !seen.add(idText)) continue;
      entries.add(CgflixTrendingEntry(id: idText, name: raw['nome'] as String?, type: raw['tipo'] as String?));
    }
    if (entries.isEmpty) return null;
    final title = json['titulo'];
    return CgflixTrending(
      title: title is String && title.trim().isNotEmpty ? title.trim() : cgflixTrendingTitle,
      entries: entries,
    );
  }
}

/// Reordena [items] pela ordem de [ids] (o `/Items?Ids=` do Jellyfin não garante ordem).
/// Itens que o servidor não devolveu (apagados, sem permissão) simplesmente somem.
List<T> cgflixOrderByIds<T>(List<T> items, List<String> ids, String Function(T) idOf) {
  final byId = {for (final item in items) idOf(item): item};
  return [
    for (final id in ids)
      if (byId[id] != null) byId[id] as T,
  ];
}

// ---------------------------------------------------------------------------
// Chips Filmes · Séries · Animes

enum CgflixChipKind { movies, shows, animes }

class CgflixLibraryChip {
  const CgflixLibraryChip(this.kind, this.library);
  final CgflixChipKind kind;
  final MediaLibrary library;

  String get label => switch (kind) {
    CgflixChipKind.movies => 'Filmes',
    CgflixChipKind.shows => 'Séries',
    CgflixChipKind.animes => 'Animes',
  };
}

/// Minúsculas e sem acento, para comparar nomes de biblioteca.
String cgflixNormalize(String text) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final lower = text.toLowerCase().trim();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString();
}

bool _isAnimeLibrary(MediaLibrary library) {
  final name = cgflixNormalize(library.title);
  return name == 'animes' || name == 'anime';
}

/// Filmes = primeira biblioteca de filmes; Séries = primeira de séries que não é a de
/// animes; Animes = biblioteca de séries chamada "Animes". Chip sem biblioteca some.
List<CgflixLibraryChip> cgflixLibraryChips(List<MediaLibrary> libraries) {
  final visible = libraries.where((l) => !l.hidden).toList();
  MediaLibrary? movies;
  MediaLibrary? shows;
  MediaLibrary? animes;
  for (final library in visible) {
    if (library.kind == MediaKind.movie) {
      movies ??= library;
    } else if (library.kind == MediaKind.show) {
      if (_isAnimeLibrary(library)) {
        animes ??= library;
      } else {
        shows ??= library;
      }
    }
  }
  return [
    if (movies != null) CgflixLibraryChip(CgflixChipKind.movies, movies),
    if (shows != null) CgflixLibraryChip(CgflixChipKind.shows, shows),
    if (animes != null) CgflixLibraryChip(CgflixChipKind.animes, animes),
  ];
}

// ---------------------------------------------------------------------------
// Gêneros

/// Escolhe os gêneros que viram linha: os com mais títulos primeiro (quando o servidor
/// manda as contagens), sem repetidos nem vazios, no máximo [max].
List<String> cgflixPickGenres(List<Map<String, dynamic>> raw, {int max = cgflixMaxGenreRows}) {
  int? countOf(Map<String, dynamic> genre) {
    final movies = genre['MovieCount'];
    final series = genre['SeriesCount'];
    if (movies is! num && series is! num) return null;
    return (movies is num ? movies.toInt() : 0) + (series is num ? series.toInt() : 0);
  }

  final seen = <String>{};
  final entries = <({String name, int? count, int index})>[];
  for (var i = 0; i < raw.length; i++) {
    final name = raw[i]['Name'];
    if (name is! String || name.trim().isEmpty) continue;
    if (!seen.add(cgflixNormalize(name))) continue;
    final count = countOf(raw[i]);
    if (count == 0) continue;
    entries.add((name: name.trim(), count: count, index: i));
  }
  final hasCounts = entries.any((e) => e.count != null);
  if (hasCounts) {
    entries.sort((a, b) {
      final byCount = (b.count ?? 0).compareTo(a.count ?? 0);
      return byCount != 0 ? byCount : a.index.compareTo(b.index);
    });
  }
  return [for (final e in entries.take(max)) e.name];
}
