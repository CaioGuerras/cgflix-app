// Início do CGFLIX no celular ("só o nosso acervo"), na ordem combinada:
// destaque, Continuar assistindo, Em alta no Brasil (Top 10), Lançamentos, Novos episódios,
// Novidades em filmes, Novidades em séries e animes e as linhas por gênero.
// Cada linha carrega sozinha (cache do aparelho primeiro). Sem servidor Jellyfin (só Plex),
// mostra a Início original do upstream.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../utils/global_key_utils.dart';
import '../../media/media_item.dart';
import '../../mixins/refreshable.dart';
import '../../mixins/tab_visibility_aware.dart';
import '../../navigation/main_screen_scope.dart';
import '../../profiles/active_profile_provider.dart';
import '../../profiles/profile_avatar.dart';
import '../../providers/discover_provider.dart';
import '../../providers/multi_server_provider.dart';
import '../../screens/discover_screen.dart';
import '../../screens/profile/profile_switch_screen.dart';
import '../../services/jellyfin_client.dart';
import '../../services/watch_actions.dart';
import '../../utils/app_logger.dart';
import '../../widgets/app_icon.dart';
import '../cgflix_style.dart';
import 'cgflix_actions.dart';
import 'cgflix_cards.dart';
import 'cgflix_hero.dart';
import 'cgflix_home_logic.dart';
import 'cgflix_home_repository.dart';
import 'cgflix_preview_sheet.dart';

class CgflixHomeScreen extends StatefulWidget {
  const CgflixHomeScreen({super.key});

  @override
  State<CgflixHomeScreen> createState() => _CgflixHomeScreenState();
}

class _CgflixHomeScreenState extends State<CgflixHomeScreen>
    with Refreshable, FullRefreshable, TabVisibilityAware, WidgetsBindingObserver {
  final _fallbackKey = GlobalKey();
  final _scrollController = ScrollController();
  late final DiscoverProvider _discover;
  late final MultiServerProvider _servers;

  JellyfinClient? _client;
  CgflixHomeRepository? _repository;
  bool _tabVisible = true;
  bool _appActive = true;

  /// Muda a cada "puxar para atualizar": as linhas renascem e buscam de novo.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _discover = context.read<DiscoverProvider>();
    _servers = context.read<MultiServerProvider>();
    _discover.addListener(_onChanged);
    _servers.addListener(_onServersChanged);
    _onServersChanged();
    unawaited(_discover.load());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _discover.removeListener(_onChanged);
    _servers.removeListener(_onServersChanged);
    _repository?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  /// Usa o primeiro servidor Jellyfin conectado. Trocou de servidor/usuário, troca o repositório.
  void _onServersChanged() {
    final client = _servers.serverManager.visibleOnlineClients.values.whereType<JellyfinClient>().firstOrNull;
    final same =
        client != null &&
        _client != null &&
        client.serverId == _client!.serverId &&
        client.cgflixUserId == _client!.cgflixUserId;
    if (same || (client == null && _client == null)) {
      _onChanged();
      return;
    }
    _repository?.dispose();
    _client = client;
    _repository = client == null ? null : CgflixHomeRepository(client);
    _onChanged();
  }

  bool get _hasOnlineServer => _servers.serverManager.visibleOnlineClients.isNotEmpty;

  /// Sem Jellyfin, mas com Plex: a Início original cuida de tudo.
  bool get _useFallback => _repository == null && _hasOnlineServer;

  // --- ganchos do MainScreen -------------------------------------------------

  @override
  void refresh() {
    if (_useFallback) {
      if (_fallbackKey.currentState case final Refreshable s) s.refresh();
      return;
    }
    if (_discover.refreshIfStale()) return;
    unawaited(_discover.refreshContinueWatching());
  }

  @override
  void fullRefresh() {
    if (_useFallback) {
      if (_fallbackKey.currentState case final FullRefreshable s) s.fullRefresh();
      return;
    }
    unawaited(_discover.load());
    if (mounted) setState(() => _generation++);
  }

  @override
  void primeRefresh() {
    if (_discover.isLoadInFlight) return;
    fullRefresh();
  }

  @override
  void onTabShown() {
    if (_fallbackKey.currentState case final TabVisibilityAware s) s.onTabShown();
    setState(() => _tabVisible = true);
    _discover.refreshIfStale();
  }

  @override
  void onTabHidden() {
    if (_fallbackKey.currentState case final TabVisibilityAware s) s.onTabHidden();
    setState(() => _tabVisible = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final active = state == AppLifecycleState.resumed;
    if (active != _appActive) setState(() => _appActive = active);
    if (active && !_useFallback) unawaited(_discover.refreshContinueWatching());
  }

  Future<void> _pullToRefresh() async {
    _repository?.forgetMemory();
    setState(() => _generation++);
    await Future.wait([
      _discover.refreshNow(),
      // Dá tempo para o gesto terminar com a animação, mesmo com tudo vindo do cache.
      Future<void>.delayed(const Duration(milliseconds: 600)),
    ]);
  }

  // --- tela ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_useFallback) return DiscoverScreen(key: _fallbackKey);
    final repository = _repository;
    final media = MediaQuery.of(context);
    final heroHeight = (media.size.width * 1.15).clamp(360.0, media.size.height * 0.68);

    return Scaffold(
      backgroundColor: CgflixColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            color: CgflixColors.accent,
            backgroundColor: CgflixColors.surface,
            edgeOffset: media.padding.top + 56,
            onRefresh: _pullToRefresh,
            child: CustomScrollView(
              key: const PageStorageKey('cgflix-home'),
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: repository == null
                  ? [
                      SliverToBoxAdapter(child: _HeroSkeleton(height: heroHeight)),
                      const SliverToBoxAdapter(child: CgflixSkeletonRow(wide: true)),
                      const SliverToBoxAdapter(child: CgflixSkeletonRow()),
                    ]
                  : _buildSlivers(repository, heroHeight),
            ),
          ),
          _TopBar(scrollController: _scrollController, repository: repository, generation: _generation),
        ],
      ),
    );
  }

  List<Widget> _buildSlivers(CgflixHomeRepository repository, double heroHeight) {
    final key = '${repository.client.serverId.value}:$_generation';
    return [
      SliverToBoxAdapter(
        child: _StreamSection<CgflixRowData>(
          key: ValueKey('hero:$key'),
          stream: repository.watchHero,
          loading: _HeroSkeleton(height: heroHeight),
          builder: (data) => data.items.isEmpty
              ? SizedBox(height: MediaQuery.paddingOf(context).top + 72)
              : CgflixHero(items: data.items, height: heroHeight, paused: !_tabVisible || !_appActive),
        ),
      ),
      SliverToBoxAdapter(child: _ContinueWatchingRow(discover: _discover)),
      SliverToBoxAdapter(
        child: _StreamSection<CgflixRowData>(
          key: ValueKey('trending:$key'),
          stream: repository.watchTrending,
          loading: const CgflixSkeletonRow(),
          builder: (data) => _Top10Row(data: data),
        ),
      ),
      for (final kind in cgflixFixedRowOrder.skip(2))
        SliverToBoxAdapter(
          child: _StreamSection<CgflixRowData>(
            key: ValueKey('${kind.name}:$key'),
            stream: () => repository.watchRow(kind),
            loading: CgflixSkeletonRow(wide: kind == CgflixRowKind.newEpisodes),
            builder: (data) => _ItemsRow(
              title: cgflixRowTitle(kind),
              items: data.items,
              storageKey: kind.name,
              wide: kind == CgflixRowKind.newEpisodes,
            ),
          ),
        ),
      _GenreRows(key: ValueKey('genres:$key'), repository: repository),
      SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24)),
    ];
  }
}

// ---------------------------------------------------------------------------
// Peças

/// Assina um fluxo de dados só quando a linha é montada (as linhas de baixo carregam
/// quando chegam perto da tela) e troca o esqueleto pelo conteúdo com fade.
class _StreamSection<T> extends StatefulWidget {
  const _StreamSection({super.key, required this.stream, required this.loading, required this.builder});
  final Stream<T> Function() stream;
  final Widget loading;
  final Widget Function(T data) builder;

  @override
  State<_StreamSection<T>> createState() => _StreamSectionState<T>();
}

class _StreamSectionState<T> extends State<_StreamSection<T>> {
  StreamSubscription<T>? _subscription;
  T? _data;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stream().listen((data) {
      if (mounted) setState(() => _data = data);
    }, onError: (Object e) => appLogger.w('CGFLIX: linha da Início falhou', error: e));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return AnimatedSize(
      duration: CgflixMotion.medium,
      curve: CgflixMotion.curve,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: CgflixMotion.medium,
        switchInCurve: CgflixMotion.curve,
        child: KeyedSubtree(
          key: ValueKey(data == null ? 'loading' : 'data:${identityHashCode(data)}'),
          child: data == null ? widget.loading : widget.builder(data),
        ),
      ),
    );
  }
}

/// Tag única por linha + item (o mesmo título pode aparecer em duas linhas).
String _heroTag(String row, MediaItem item) => 'cgflix:$row:${item.globalKey}';

class _ItemsRow extends StatelessWidget {
  const _ItemsRow({required this.title, required this.items, required this.storageKey, this.wide = false});
  final String title;
  final List<MediaItem> items;
  final String storageKey;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return CgflixRow(
      title: title,
      storageKey: storageKey,
      height: wide ? cgflixWideHeight + CgflixWideCard.titleBlockHeight : cgflixPosterHeight,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final client = cgflixClientFor(context, item);
        if (wide) {
          return CgflixWideCard(
            item: item,
            client: client,
            showProgress: false,
            onTap: () => showCgflixPreview(context, item),
            onLongPress: () => showCgflixPreview(context, item),
          );
        }
        final tag = _heroTag(storageKey, item);
        return CgflixPosterCard(
          item: item,
          client: client,
          heroTag: tag,
          onTap: () => showCgflixPreview(context, item, heroTag: tag),
          onLongPress: () => showCgflixPreview(context, item, heroTag: tag),
        );
      },
    );
  }
}

class _Top10Row extends StatelessWidget {
  const _Top10Row({required this.data});
  final CgflixRowData data;

  @override
  Widget build(BuildContext context) {
    final items = data.items.take(10).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return CgflixRow(
      title: cgflixRowTitle(CgflixRowKind.trending, trendingTitle: data.title),
      storageKey: 'trending',
      height: cgflixPosterHeight,
      spacing: 4,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final tag = _heroTag('trending', item);
        return CgflixTop10Card(
          rank: index + 1,
          item: item,
          client: cgflixClientFor(context, item),
          heroTag: tag,
          onTap: () => showCgflixPreview(context, item, heroTag: tag),
          onLongPress: () => showCgflixPreview(context, item, heroTag: tag),
        );
      },
    );
  }
}

/// Continuar assistindo: vem do DiscoverProvider do upstream (mesma regra de "próximo
/// episódio" e de atualização). Tocar = continua direto; segurar = remover da linha.
class _ContinueWatchingRow extends StatelessWidget {
  const _ContinueWatchingRow({required this.discover});
  final DiscoverProvider discover;

  Future<void> _confirmRemove(BuildContext context, MediaItem item) async {
    final remove = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: CgflixColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                item.grandparentTitle ?? item.displayTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(cgflixEpisodeLabel(item)),
            ),
            ListTile(
              leading: const AppIcon(Symbols.remove_circle_rounded, fill: 1),
              title: const Text('Remover de Continuar assistindo'),
              onTap: () => Navigator.of(sheetContext).pop(true),
            ),
            ListTile(
              leading: const AppIcon(Symbols.info_rounded, fill: 1),
              title: const Text('Detalhes'),
              onTap: () => Navigator.of(sheetContext).pop(false),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || remove == null) return;
    if (!remove) {
      await cgflixOpenDetails(context, item);
      return;
    }
    try {
      await WatchActions.removeFromContinueWatching(context, item);
    } catch (e) {
      appLogger.w('CGFLIX: remover de Continuar assistindo falhou', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = discover.onDeck;
    final Widget child;
    if (items.isEmpty && discover.isLoading) {
      child = const CgflixSkeletonRow(key: ValueKey('loading'), wide: true);
    } else if (items.isEmpty) {
      child = const SizedBox.shrink(key: ValueKey('empty'));
    } else {
      child = CgflixRow(
        key: const ValueKey('row'),
        title: cgflixRowTitle(CgflixRowKind.continueWatching),
        storageKey: 'continue',
        height: cgflixWideHeight + CgflixWideCard.titleBlockHeight,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return CgflixWideCard(
            item: item,
            client: cgflixClientFor(context, item),
            onTap: () => cgflixPlay(context, item),
            onLongPress: () => _confirmRemove(context, item),
          );
        },
      );
    }
    return AnimatedSize(
      duration: CgflixMotion.medium,
      curve: CgflixMotion.curve,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(duration: CgflixMotion.medium, child: child),
    );
  }
}

/// Linhas por gênero: a lista de gêneros vem primeiro; cada linha só busca seus títulos
/// quando chega perto da tela (SliverList monta sob demanda).
class _GenreRows extends StatefulWidget {
  const _GenreRows({super.key, required this.repository});
  final CgflixHomeRepository repository;

  @override
  State<_GenreRows> createState() => _GenreRowsState();
}

class _GenreRowsState extends State<_GenreRows> {
  StreamSubscription<List<String>>? _subscription;
  List<String> _genres = const [];

  @override
  void initState() {
    super.initState();
    _subscription = widget.repository.watchGenres().listen((genres) {
      if (mounted) setState(() => _genres = genres);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: _genres.length,
      itemBuilder: (context, index) {
        final genre = _genres[index];
        return _StreamSection<CgflixRowData>(
          key: ValueKey('genre:$genre'),
          stream: () => widget.repository.watchRow(CgflixRowKind.genre, genre: genre),
          loading: const CgflixSkeletonRow(),
          builder: (data) => _ItemsRow(
            title: cgflixRowTitle(CgflixRowKind.genre, genre: genre),
            items: data.items,
            storageKey: 'genre:$genre',
          ),
        );
      },
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return CgflixShimmer(
      child: Container(height: height, color: CgflixColors.surface),
    );
  }
}

/// Topo da Início: chips Filmes · Séries · Animes e o avatar. Transparente sobre o
/// destaque; ganha fundo aos poucos quando a página rola (nada de barra opaca de cara).
class _TopBar extends StatefulWidget {
  const _TopBar({required this.scrollController, required this.repository, required this.generation});
  final ScrollController scrollController;
  final CgflixHomeRepository? repository;
  final int generation;

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  List<CgflixLibraryChip> _chips = const [];

  @override
  void initState() {
    super.initState();
    _loadChips();
  }

  @override
  void didUpdateWidget(_TopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository || oldWidget.generation != widget.generation) _loadChips();
  }

  Future<void> _loadChips() async {
    final repository = widget.repository;
    if (repository == null) return;
    final chips = await repository.chips();
    if (mounted && repository == widget.repository) setState(() => _chips = chips);
  }

  void _openLibrary(CgflixLibraryChip chip) {
    final serverId = widget.repository?.client.serverId;
    if (serverId == null) return;
    MainScreenFocusScope.of(context, listen: false)?.selectLibrary?.call(buildGlobalKey(serverId, chip.library.id));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final profiles = context.watch<ActiveProfileProvider>();
    final active = profiles.active;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: widget.scrollController,
        builder: (context, child) {
          final offset = widget.scrollController.hasClients ? widget.scrollController.offset : 0.0;
          final opacity = (offset / 160).clamp(0.0, 0.92);
          return DecoratedBox(
            decoration: BoxDecoration(color: CgflixColors.background.withValues(alpha: opacity)),
            child: child,
          );
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, top + 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: CgflixMotion.medium,
                  child: SingleChildScrollView(
                    key: ValueKey(_chips.length),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final chip in _chips)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(chip.label),
                              onPressed: () => _openLibrary(chip),
                              backgroundColor: const Color(0x3307060A),
                              side: const BorderSide(color: Colors.white38),
                              shape: const StadiumBorder(),
                              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Trocar perfil',
                onPressed: () => Navigator.of(
                  context,
                  rootNavigator: true,
                ).push(MaterialPageRoute(builder: (_) => const ProfileSwitchScreen())),
                icon: active != null
                    ? ProfileAvatar(profile: active, size: 32, avatarUrl: profiles.avatarUrlFor(active.id))
                    : const AppIcon(Symbols.account_circle_rounded, fill: 1, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
