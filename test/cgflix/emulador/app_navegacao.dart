// App de teste do job "Emulador" do CI (Etapa 1D). NÃO vai para o APK de verdade: o CI compila
// este arquivo como alvo (`flutter build apk --debug -t test/cgflix/emulador/app_navegacao.dart`).
//
// Usa as peças reais do CGFLIX (tema único, barra do topo, menu do usuário, contas de altura do
// destaque, transições) com dados falsos: nada de login nem servidor. O roteiro em
// scripts/cgflix/emulador_navegacao.py toca nos itens pelo nome (TalkBack/uiautomator), gira a
// tela e tira as capturas.
import 'package:flutter/material.dart';

import 'package:plezy/cgflix/cgflix_layout.dart';
import 'package:plezy/cgflix/cgflix_navigation.dart';
import 'package:plezy/cgflix/cgflix_style.dart';
import 'package:plezy/cgflix/cgflix_theme.dart';

const _titulos = [
  'Duna',
  'Ainda Estou Aqui',
  'Cidade de Deus',
  'Bacurau',
  'O Auto da Compadecida',
  'Central do Brasil',
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  cgflixEnableEdgeToEdge();
  CgflixPages.search = (_) => const _BuscaFalsa();
  CgflixPages.downloads = (_) => const _PaginaSimples(titulo: 'Baixados', texto: 'Nenhum título baixado ainda');
  CgflixPages.settings = () => MaterialPageRoute<void>(
    builder: (_) => const _PaginaSimples(titulo: 'Configurações', texto: 'Configurações (falsas)'),
  );
  CgflixPages.myRequests = (_) => const _PaginaSimples(titulo: 'Meus pedidos', texto: 'Pedidos (falsos)');
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
                SliverToBoxAdapter(child: _LinhaFalsa(titulo: linha)),
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
  const _LinhaFalsa({required this.titulo});
  final String titulo;

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
              itemCount: _titulos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Container(
                width: 120,
                decoration: BoxDecoration(color: CgflixColors.surfaceHigh, borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(8),
                child: Text(_titulos[i], maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Busca falsa: campo com foco e um resultado que abre a página do título.
class _BuscaFalsa extends StatelessWidget {
  const _BuscaFalsa();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(autofocus: false, decoration: InputDecoration(hintText: 'Títulos, pessoas...')),
          const SizedBox(height: 16),
          for (final t in _titulos.take(3))
            ListTile(
              title: Text(t),
              subtitle: const Text('Filme · 2024'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _TituloFalso(titulo: t))),
            ),
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
