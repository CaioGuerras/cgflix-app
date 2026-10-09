// App de teste do job "Emulador" do CI (Etapa 1D/1E). NÃO vai para o APK de verdade: o CI compila
// este arquivo como alvo (`flutter build apk --debug -t test/cgflix/emulador/app_navegacao.dart`).
//
// Usa as peças reais do CGFLIX (tema único, barra do topo, menu do usuário, contas de altura do
// destaque, transições, seção "Disponível para pedir" e "Meus pedidos") com dados falsos: nada de
// login nem servidor. O roteiro em scripts/cgflix/emulador_navegacao.py toca nos itens pelo nome
// (TalkBack/uiautomator), gira a tela e tira as capturas.
import 'package:flutter/material.dart';

import 'package:plezy/cgflix/cgflix_layout.dart';
import 'package:plezy/cgflix/cgflix_navigation.dart';
import 'package:plezy/cgflix/cgflix_style.dart';
import 'package:plezy/cgflix/cgflix_theme.dart';
import 'package:plezy/cgflix/requests/cgflix_requests_ui.dart';
import 'package:plezy/cgflix/requests/cgflix_seerr.dart';

/// Títulos falsos de cada categoria (Etapa 1E: cada chip só mostra os seus).
const _porCategoria = {
  null: ['Duna', 'Ainda Estou Aqui', 'Ruptura', 'Frieren', 'Cidade de Deus', 'Spy x Family'],
  'Filmes': ['Duna', 'Bacurau', 'Ainda Estou Aqui', 'Cidade de Deus', 'O Auto da Compadecida', 'Central do Brasil'],
  'Séries': ['Ruptura', 'Sintonia', 'Cangaço Novo', 'The Bear', 'Severance', 'Arcane'],
  'Animes': ['Frieren', 'Jujutsu Kaisen', 'Spy x Family', 'One Piece', 'Dandadan', 'Solo Leveling'],
};

List<String> get _titulos => _porCategoria[null]!;

/// Seerr falso: "Disponível para pedir" e "Meus pedidos" sem servidor.
class _PedidosFalsos implements CgflixRequestsBackend {
  @override
  Future<List<CgflixRequestable>> search(String query) async => const [
    CgflixRequestable(tmdbId: 1, isMovie: true, title: 'Duna: Parte Três', year: 2026),
    CgflixRequestable(tmdbId: 2, isMovie: false, title: 'Duna: A Profecia', year: 2024),
    CgflixRequestable(tmdbId: 3, isMovie: true, title: 'Duna (1984)', year: 1984, state: CgflixRequestState.requested),
    CgflixRequestable(
      tmdbId: 4,
      isMovie: true,
      title: 'Duna de Jodorowsky',
      year: 2013,
      state: CgflixRequestState.downloading,
    ),
  ];

  @override
  Future<List<CgflixSeasonChoice>> seasons(int tmdbId) async => const [
    CgflixSeasonChoice(number: 1, name: 'Temporada 1', episodes: 6),
    CgflixSeasonChoice(number: 2, name: 'Temporada 2', episodes: 6),
  ];

  @override
  Future<void> request(CgflixRequestable item, {List<int>? seasons}) async {}

  @override
  Future<List<CgflixMyRequest>> myRequests() async => const [
    CgflixMyRequest(
      id: 1,
      tmdbId: 2,
      isMovie: false,
      title: 'Duna: A Profecia',
      year: 2024,
      status: CgflixMyRequestStatus.waitingApproval,
      seasons: [1, 2],
    ),
    CgflixMyRequest(
      id: 2,
      tmdbId: 5,
      isMovie: true,
      title: 'Ainda Estou Aqui',
      year: 2024,
      status: CgflixMyRequestStatus.available,
    ),
    CgflixMyRequest(id: 3, tmdbId: 6, isMovie: false, title: 'Frieren', status: CgflixMyRequestStatus.downloading),
  ];

  @override
  Future<CgflixTitleInfo> titleInfo(int tmdbId, {required bool isMovie}) async =>
      (title: 'Título $tmdbId', year: null, posterUrl: null);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  cgflixEnableEdgeToEdge();
  CgflixPages.search = (_) => const _BuscaFalsa();
  CgflixPages.downloads = (_) => const _PaginaSimples(titulo: 'Baixados', texto: 'Nenhum título baixado ainda');
  CgflixPages.settings = () => MaterialPageRoute<void>(
    builder: (_) => const _PaginaSimples(titulo: 'Configurações', texto: 'Configurações (falsas)'),
  );
  CgflixRequests.debugOverride = _PedidosFalsos();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, theme: cgflixAppTheme(), home: const _InicioFalsa()));
}

class _InicioFalsa extends StatefulWidget {
  const _InicioFalsa();

  @override
  State<_InicioFalsa> createState() => _InicioFalsaState();
}

class _InicioFalsaState extends State<_InicioFalsa> {
  String? _filtro;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final heroHeight = cgflixHeroHeight(media.size);
    final compact = cgflixHeroCompact(media.size);
    return Scaffold(
      backgroundColor: CgflixColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: heroHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF3B1466), CgflixColors.background],
                    ),
                  ),
                  alignment: compact ? Alignment.bottomLeft : Alignment.bottomCenter,
                  padding: EdgeInsets.fromLTRB(24 + media.padding.left, 0, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                    children: [
                      Text(
                        _filtro == null ? 'Duna' : 'Duna · $_filtro',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: CgflixColors.accentPressed),
                        onPressed: () {},
                        child: const Text('Assistir'),
                      ),
                    ],
                  ),
                ),
              ),
              for (final linha in ['Continuar assistindo', 'Em alta no Brasil', 'Lançamentos'])
                SliverToBoxAdapter(
                  child: _LinhaFalsa(titulo: linha, titulos: _porCategoria[_filtro]!),
                ),
              SliverToBoxAdapter(child: SizedBox(height: media.padding.bottom + 24)),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8 + media.padding.left, media.padding.top + 4, 8 + media.padding.right, 0),
              child: CgflixTopBar(
                onClearFilter: _filtro == null ? null : () => setState(() => _filtro = null),
                chips: [
                  for (final c in ['Filmes', 'Séries', 'Animes'])
                    if (_filtro == null || _filtro == c)
                      CgflixTopBarChip(
                        label: c,
                        selected: _filtro == c,
                        onPressed: () => setState(() => _filtro = _filtro == c ? null : c),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaFalsa extends StatelessWidget {
  const _LinhaFalsa({required this.titulo, required this.titulos});
  final String titulo;
  final List<String> titulos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(titulo, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: titulos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Container(
                width: 120,
                decoration: BoxDecoration(color: CgflixColors.surfaceHigh, borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(8),
                child: Text(titulos[i], maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Busca falsa: o que já temos (abre a página do título) e, logo abaixo, a seção real
/// "Disponível para pedir" com o Seerr falso.
class _BuscaFalsa extends StatelessWidget {
  const _BuscaFalsa();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: TextEditingController(text: 'Duna'),
            decoration: const InputDecoration(hintText: 'Títulos, pessoas...'),
          ),
          const SizedBox(height: 16),
          for (final t in _titulos.take(1))
            ListTile(
              title: Text(t),
              subtitle: const Text('Filme · 2021'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _TituloFalso(titulo: t))),
            ),
          const CgflixRequestSection(query: 'Duna'),
        ],
      ),
    );
  }
}

/// Página do título: duas colunas quando cabe (deitado), uma em pé.
class _TituloFalso extends StatelessWidget {
  const _TituloFalso({required this.titulo});
  final String titulo;

  @override
  Widget build(BuildContext context) {
    final poster = AspectRatio(
      aspectRatio: 2 / 3,
      child: DecoratedBox(
        decoration: BoxDecoration(color: CgflixColors.surfaceHigh, borderRadius: BorderRadius.circular(8)),
      ),
    );
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('2024 · 2h 46min · 14 anos · Dublado · Legendado'),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: CgflixColors.accentPressed),
          onPressed: () {},
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Assistir'),
        ),
        const SizedBox(height: 16),
        const Text(
          'Sinopse falsa para o teste do emulador. Paul Atreides une forças com os Fremen enquanto busca vingança.',
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: constraints.maxWidth > 600
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 200, child: poster),
                    const SizedBox(width: 24),
                    Expanded(child: info),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: SizedBox(width: 180, child: poster)),
                    const SizedBox(height: 16),
                    info,
                  ],
                ),
        ),
      ),
    );
  }
}

class _PaginaSimples extends StatelessWidget {
  const _PaginaSimples({required this.titulo, required this.texto});
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(child: Text(texto)),
    );
  }
}
