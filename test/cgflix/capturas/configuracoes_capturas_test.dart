// Capturas do refino 2b (item G): Configurações antes (1.6.0) × depois (1.6.1), nos dois temas
// (Isis e Heitor), com a fonte normal e a 200%. Telas reais do app com a Inter e os Material
// Symbols Rounded de verdade, num celular de 412 dp de largura; a altura é grande para caber a
// tela inteira (a captura mostra a lista toda, sem precisar rolar).
//
// Só roda quando pedido (não pesa no `flutter test` comum):
//   CGFLIX_CAPTURAS=docs/prints/refino2b/depois flutter test test/cgflix/capturas/configuracoes_capturas_test.dart
// O "antes" é o mesmo teste rodado na 1.6.0 (as telas que eram cartões são abertas com um toque).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plezy/cgflix/cgflix_theme.dart';
import 'package:plezy/connection/connection_registry.dart';
import 'package:plezy/database/app_database.dart';
import 'package:plezy/i18n/strings.g.dart';
import 'package:plezy/media/account_preferences.dart';
import 'package:plezy/media/account_preferences_source.dart';
import 'package:plezy/media/account_preferences_target.dart';
import 'package:plezy/media/account_ref.dart';
import 'package:plezy/media/media_backend.dart';
import 'package:plezy/media/media_library.dart';
import 'package:plezy/media/media_server_user_profile.dart';
import 'package:plezy/profiles/active_profile_provider.dart';
import 'package:plezy/profiles/plex_home_service.dart';
import 'package:plezy/profiles/profile_connection_registry.dart';
import 'package:plezy/profiles/profile_registry.dart';
import 'package:plezy/providers/account_preferences_controller.dart';
import 'package:plezy/providers/download_provider.dart';
import 'package:plezy/providers/hidden_libraries_provider.dart';
import 'package:plezy/providers/libraries_provider.dart';
import 'package:plezy/providers/seerr_account_provider.dart';
import 'package:plezy/providers/theme_provider.dart';
import 'package:plezy/providers/trackers_provider.dart';
import 'package:plezy/screens/settings/account_preferences_screen.dart';
import 'package:plezy/screens/settings/playback_settings_screen.dart';
import 'package:plezy/screens/settings/settings_screen.dart';
import 'package:plezy/screens/settings/subtitle_styling_screen.dart';
import 'package:plezy/services/account_preferences_accounts.dart';
import 'package:plezy/services/account_preferences_repository.dart';
import 'package:plezy/services/download_manager_service.dart';
import 'package:plezy/services/download_storage_service.dart';
import 'package:plezy/services/settings_service.dart';
import 'package:plezy/services/storage_service.dart';
import 'package:plezy/utils/platform_detector.dart';
import 'package:provider/provider.dart';

import '../../test_helpers/backend_client_fixtures.dart';
import '../../test_helpers/io_fakes.dart';
import '../../test_helpers/prefs.dart';

final _destino = Platform.environment['CGFLIX_CAPTURAS'];

/// Fonte normal e fonte 200% (Configurações do Android › Tamanho da fonte no máximo).
const _escalas = {'fonte100': 1.0, 'fonte200': 2.0};

Future<void> _carregarFontes() async {
  Future<void> carregar(String familia, List<String> arquivos) async {
    final loader = FontLoader(familia);
    for (final arquivo in arquivos) {
      loader.addFont(Future.value(ByteData.sublistView(File(arquivo).readAsBytesSync())));
    }
    await loader.load();
  }

  await carregar('Inter', [
    for (final peso in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) 'assets/fonts/Inter-$peso.ttf',
  ]);
  final pacote = File('.dart_tool/package_config.json').readAsStringSync();
  final raiz = RegExp(r'"rootUri":\s*"([^"]*material_symbols_icons[^"]*)"').firstMatch(pacote)!.group(1)!;
  final dir = Uri.parse(raiz).isAbsolute ? Uri.parse(raiz).toFilePath() : '.dart_tool/$raiz';
  await carregar('packages/material_symbols_icons/MaterialSymbolsRounded', [
    '$dir/lib/fonts/MaterialSymbolsRounded.ttf',
  ]);
}

Future<void> _salvar(WidgetTester tester, String nome) async {
  await tester.runAsync(() async {
    final image = await captureImage(tester.element(find.byKey(const ValueKey('cgflix-captura'))));
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final arquivo = File('$_destino/$nome.png')..createSync(recursive: true);
    arquivo.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// Conta Jellyfin de mentira com áudio e legenda em português (como o CGFLIX configura).
const _ref = AccountRef.mediaBrowser(backend: MediaBackend.jellyfin, connectionId: 'srv-1/user-1');
const _alvo = AccountPreferenceTarget(ref: _ref, label: 'CGFLIX', subtitle: 'caioguerras', isDefaultConnection: true);

class _FonteDaConta implements AccountPreferencesSource {
  @override
  AccountPreferencesCapabilities get capabilities => AccountPreferencesCapabilities.jellyfin;

  @override
  Future<AccountPreferences> read() async => const AccountPreferences(
    preferredAudioLanguage: 'por',
    playDefaultAudioTrack: false,
    preferredSubtitleLanguage: 'por',
    subtitlePlaybackMode: SubtitlePlaybackMode.smart,
    displayMissingEpisodes: false,
    hidePlayedInLatest: true,
    displayCollectionsView: false,
  );

  @override
  Future<AccountPreferences> write(AccountPreferencesPatch patch, {void Function()? checkCurrent}) => read();
}

class _ContaFalsa extends AccountPreferencesController {
  _ContaFalsa(this._repositorio);
  final AccountPreferencesRepository _repositorio;

  @override
  AccountPreferencesRepository get repository => _repositorio;

  @override
  List<AccountPreferenceAccount> get accounts => [
    AccountPreferenceAccount(target: _alvo, connection: testJellyfinConnection(userName: 'caioguerras')),
  ];
}

class _Bibliotecas extends LibrariesProvider {
  @override
  List<MediaLibrary> get libraries => const [];
}

class _SemBibliotecasOcultas implements StorageService {
  @override
  Set<String> getHiddenLibraries() => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PastaGravavel extends Fake implements DownloadStorageService {
  @override
  Future<bool> isDirectoryWritable(Directory dir) async => true;
}

/// Monta [home] com tudo que as Configurações leem (perfis, bibliotecas, contas, baixados).
Future<void> _montar(WidgetTester tester, CgflixThemeVariant variante, double escala, Widget home) async {
  // Bem alta para caber a lista inteira; 200% precisa do dobro.
  final tela = Size(412, escala > 1 ? 3600 : 2000);
  tester.view.physicalSize = tela * 1.5;
  tester.view.devicePixelRatio = 1.5;
  tester.platformDispatcher.textScaleFactorTestValue = escala;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final database = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(database.close);
  final connections = ConnectionRegistry(database);
  final profileConnections = ProfileConnectionRegistry(database);
  final plexHome = PlexHomeService(
    connections: connections,
    profileConnections: profileConnections,
    plexHomeUserFetcher: (_) async => const [],
  );
  final perfis = ActiveProfileProvider(
    registry: ProfileRegistry(database),
    plexHome: plexHome,
    connections: connections,
    profileConnections: profileConnections,
  );
  final ocultas = HiddenLibrariesProvider(storageService: _SemBibliotecasOcultas());
  await ocultas.ensureInitialized();
  final repositorio = AccountPreferencesRepository(sourceFor: (_) async => _FonteDaConta());
  final settingsService = SettingsService.instance;
  await tester.runAsync(() => DownloadStorageService.instance.initialize(settingsService));
  final downloads = DownloadManagerService(
    database: database,
    storageService: _PastaGravavel(),
    clientResolver: (_, {clientScopeId}) => null,
    downloadLocationReader: () => (path: null, type: null),
    downloadPathWriter: (_) async {},
    downloadPathTypeWriter: (_) async {},
    downloadStorageRefresher: () async {},
  )..recoveryFuture = Future<void>.value();
  final theme = ThemeProvider();
  addTearDown(theme.dispose);

  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey('cgflix-captura'),
      child: TranslationProvider(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: theme),
            ChangeNotifierProvider<ActiveProfileProvider>.value(value: perfis),
            ChangeNotifierProvider<LibrariesProvider>.value(value: _Bibliotecas()),
            ChangeNotifierProvider<HiddenLibrariesProvider>.value(value: ocultas),
            ChangeNotifierProvider<TrackersProvider>.value(value: TrackersProvider()),
            ChangeNotifierProvider<SeerrAccountProvider>.value(value: SeerrAccountProvider()),
            ChangeNotifierProvider<DownloadProvider>.value(
              value: DownloadProvider.forTesting(downloadManager: downloads, database: database),
            ),
            ChangeNotifierProvider<AccountPreferencesController>.value(value: _ContaFalsa(repositorio)),
            Provider<AccountPreferencesRepository>.value(value: repositorio),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: cgflixAppTheme(variante).copyWith(platform: TargetPlatform.android),
            home: home,
          ),
        ),
      ),
    ),
  );
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Toca no item [texto] (abre a subtela ou o cartão) e espera a animação.
Future<void> _abrir(WidgetTester tester, String texto) async {
  final alvo = find.text(texto).first;
  await tester.ensureVisible(alvo);
  await tester.pump();
  await tester.tap(alvo);
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Rola a lista até [texto] ficar no topo (cartão aberto no meio da tela principal).
Future<void> _noTopo(WidgetTester tester, String texto) async {
  final alvo = find.text(texto).last;
  await tester.runAsync(() => Scrollable.ensureVisible(tester.element(alvo), alignment: 0));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  final pular = _destino == null ? 'defina CGFLIX_CAPTURAS=<pasta> para gerar as capturas' : null;
  late Directory temporario;
  late PathProviderPlatform caminhosOriginais;

  setUpAll(() async {
    if (_destino == null) return;
    await _carregarFontes();
    await LocaleSettings.setLocale(AppLocale.pt);
  });

  setUp(() async {
    resetSharedPreferencesForTest();
    SettingsService.resetForTesting();
    DownloadStorageService.resetForTesting();
    temporario = await Directory.systemTemp.createTemp('cgflix_capturas_config_');
    caminhosOriginais = PathProviderPlatform.instance;
    PathProviderPlatform.instance = FakePathProvider(temporario);
    TvDetectionService.debugSetAppleTVOverride(false);
    PlatformDetector.debugSetIsDesktopOSOverride(false);
    await SettingsService.getInstance();
    if (_destino != null) LocaleSettings.setLocaleSync(AppLocale.pt);
  });

  tearDown(() async {
    TvDetectionService.debugSetAppleTVOverride(null);
    PlatformDetector.debugSetIsDesktopOSOverride(null);
    DownloadStorageService.resetForTesting();
    PathProviderPlatform.instance = caminhosOriginais;
    if (temporario.existsSync()) await temporario.delete(recursive: true);
  });

  for (final variante in CgflixThemeVariant.values) {
    for (final MapEntry(key: fonte, value: escala) in _escalas.entries) {
      final prefixo = '${variante.name}-$fonte';

      testWidgets('$prefixo: tela principal, Baixados e Avançado', skip: pular != null, (tester) async {
        await _montar(tester, variante, escala, const SettingsScreen());
        await _salvar(tester, '$prefixo-01-principal');

        await _abrir(tester, 'Baixados');
        await _noTopo(tester, 'Baixados');
        await _salvar(tester, '$prefixo-05-baixados');

        await _montar(tester, variante, escala, const SettingsScreen());
        await _abrir(tester, 'Avançado');
        await _noTopo(tester, 'Avançado');
        await _salvar(tester, '$prefixo-06-avancado');
      });

      testWidgets('$prefixo: Ao assistir', skip: pular != null, (tester) async {
        await _montar(tester, variante, escala, const PlaybackSettingsScreen());
        await _salvar(tester, '$prefixo-02-ao-assistir');
      });

      testWidgets('$prefixo: Áudio e legenda', skip: pular != null, (tester) async {
        await _montar(tester, variante, escala, const AccountPreferencesScreen(targets: [_alvo]));
        await _salvar(tester, '$prefixo-03-audio-e-legenda');
      });

      testWidgets('$prefixo: Estilo das legendas', skip: pular != null, (tester) async {
        await _montar(tester, variante, escala, const SubtitleStylingScreen());
        await _salvar(tester, '$prefixo-04-estilo-das-legendas');
      });
    }
  }
}
