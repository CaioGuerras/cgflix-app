# CGFLIX — o que mudou em relação ao Plezy

O CGFLIX é um fork do [Plezy](https://github.com/edde746/plezy) (GPL-3.0). A regra é **diferença mínima**: tudo que é nosso
fica em arquivos próprios e os arquivos do upstream recebem só ganchos de uma linha, para puxar as atualizações sem conflito.
Licença e créditos do Plezy continuam no `LICENSE`, no README e na tela "Sobre".

## Etapa 0 — arquivos alterados/criados

| Arquivo | Mudança |
|---|---|
| `lib/cgflix/cgflix_defaults.dart` (novo) | idioma padrão (português) e constantes do CGFLIX (cabeçalho da Início, busca) |
| `lib/services/settings_service.dart` | `_AppLocalePref.resolvedDefault` chama `cgflixResolveDefaultLocale` |
| `android/app/build.gradle.kts` | `applicationId = br.com.docaio.cgflix` (o `namespace`/pacote Kotlin continua `com.edde746.plezy`); release sem keystore assina com a chave de debug |
| `android/app/src/main/AndroidManifest.xml` | nome exibido "CGFLIX"; autoridades dos providers trocadas para o novo applicationId (evita conflito com o Plezy instalado) |
| `android/.../ExternalPlayerChannel.kt`, `SystemShelfArtworkProvider.kt` e seus testes | mesma troca das autoridades `fileprovider` / `systemshelf.artwork` |
| `android/app/src/main/res/` | ícone adaptativo (fundo `#07060a`, emblema "C com play" em vetor), ícone monocromático, mipmaps legados, banner de TV, cores do splash `#07060a` |
| `.github/workflows/cgflix-android.yml` (novo) | gera o APK de release (push no `main` e PRs; somente leitura, sem segredos) |
| `.github/workflows/cgflix-release.yml` (novo) | em tags `v*` compila, assina com keystore dos secrets (se houver) e anexa à Release |
| `.github/workflows/build.yml`, `update-packages.yml` | neutralizados fora do repositório `edde746/plezy` (usam segredos de assinatura, Sentry, winget que não temos) |
| `README.md`, `CGFLIX.md` | aviso do fork e esta página |

Mantidos de propósito: o esquema de deep link `plezy://` e a pasta de código `com.edde746.plezy` (renomear geraria conflito em todo merge).

## Etapa 1A — ajustes do teste no aparelho

O servidor **não** vem mais pré-preenchido (segurança): o campo do Jellyfin começa vazio, com a dica `https://seu.servidor.com`;
`add_jellyfin_screen.dart` voltou a ser idêntico ao upstream.

| Arquivo | Mudança |
|---|---|
| `lib/cgflix/cgflix_logo.dart`, `assets/cgflix_emblema.svg`, `pubspec.yaml` | emblema CGFLIX nas telas de marca (splash do Flutter, entrada, Sobre) |
| `lib/main.dart`, `lib/screens/auth_screen.dart`, `lib/screens/settings/about_screen.dart` | trocam o logo do Plezy pelo `CgflixEmblem` |
| `lib/screens/auth_screen.dart` | entrada só com Jellyfin (destaque) e Plex; QR/navegador do Plex dentro do fluxo do Plex; Emby não é oferecido (código mantido) |
| `lib/media/media_browser_dialect.dart` | dica neutra do campo de servidor |
| `lib/services/jellyfin_auth_header.dart`, `plex_client.dart`, `plex_auth_service.dart`, `plex_discover_client.dart`, `models/plex/plex_config.dart` | nome do app no servidor: `CGFLIX`, `CGFLIX Android`, `CGFLIX Android TV`; `X-Plex-Product: CGFLIX` |
| `lib/screens/video_player/parts/playback_services.dart` | cancela o tracker de progresso antigo antes de recriar (evita sessão duplicada) |
| `lib/screens/discover_screen.dart`, `lib/cgflix/cgflix_advanced.dart` | Início sem Recarregar/Assistir juntos/Controle remoto; puxar para atualizar; os dois recursos vão para Avançado |
| `lib/widgets/settings_section.dart`, `lib/widgets/settings_page.dart`, `lib/cgflix/cgflix_collapsible.dart` | seções recolhíveis (cartões) nas Configurações |
| `lib/screens/settings/{settings,general_settings,appearance_settings,playback_settings}_screen.dart` | usam as seções recolhíveis; cartão Avançado; mpv só em Avançado |
| `lib/services/settings_service.dart` | padrões: tema OLED, áudio/legenda do servidor (`followServerTrackSelections`), idioma português |
| `lib/cgflix/cgflix_about.dart` | dedicatória e crédito ao Plezy no Sobre |
| `lib/mixins/debounced_media_search.dart`, `lib/services/data_aggregation_service.dart`, `lib/utils/search_relevance.dart` | busca: debounce 300 ms, 5 pessoas por termo, teto de 40 resultados |
| `lib/i18n/*.i18n.json` e `strings_*.g.dart` | `app.title` = CGFLIX em todos os idiomas; português sem "Plezy" (regenerado com `dart run slang`) |
| `docs/CONFIGURACOES.md` | cada opção, onde ficou e o padrão |

Ao sincronizar com o upstream, os conflitos novos esperados estão nesses arquivos; conferir `grep -rn "CGFLIX" lib`.

## Etapa 1B — redesenho (versão 1.0.0, versionCode 200)

Tudo novo fica em `lib/cgflix/`; os arquivos do upstream recebem só ganchos marcados com `// CGFLIX`.

| Arquivo | Mudança |
|---|---|
| `pubspec.yaml` | `version: 1.0.0+200` (a Play já tinha o 152 da 1A) |
| `lib/cgflix/cgflix_version.dart`, `lib/screens/settings/about_screen.dart` | Sobre mostra "CGFLIX 1.0.0" (a chave `about.versionLabel` segue no leitor de tela) |
| `lib/cgflix/cgflix_style.dart` (novo) | cores e movimento (250–350 ms, ease-out) das telas novas |
| `lib/cgflix/cgflix_navigation.dart`, `lib/cgflix/cgflix_you_screen.dart` (novos) | barra do celular **Início · Buscar · Baixados · Você**; "Você" = perfil, Configurações, Sobre |
| `lib/screens/main_screen.dart` | ganchos: abas do celular, aba "Você" e Início do CGFLIX (só celular; TV/computador iguais ao upstream) |
| `lib/cgflix/home/` (novos) | Início "só o nosso acervo": destaque, Continuar, Em alta (Top 10), Lançamentos, Novos episódios, Novidades, gêneros, chips Filmes/Séries/Animes, prévia em painel, cache no aparelho |
| `lib/services/jellyfin_client.dart` | 1 linha: `part` de `lib/cgflix/home/cgflix_jellyfin_queries.dart` (consultas da Início) |
| `lib/services/jellyfin_client/parts/images_downloads.dart` | imagens dimensionadas pedem `quality=80` |
| `lib/cgflix/cgflix_detail.dart` (novo), `lib/screens/media_detail_screen.dart` | página do título: Hero do pôster, botão "Assistir"/"Continuar S02E05", selos Dublado/Legendado, rótulos alinhados |
| `lib/i18n/pt.i18n.json` + `strings_pt.g.dart` | "Mais como este" |
| `test/screens/media_detail_screen_test.dart` | 4 expectativas do rótulo do botão (S1E2 → "Continuar S01E02") |
| `lib/cgflix/cgflix_intro.dart` (novo), `lib/main.dart` | abertura animada (~1,4 s) no splash do Flutter; espera a animação antes da Início; pula em aberturas < 30 s |
| `lib/screens/settings/settings_screen.dart` | chave "Som da abertura" (Android) |
| `android/.../res/drawable/splash_icon.xml`, `values-v31/styles.xml`, `values-night-v31/styles.xml` | ícone animado da Splash Screen API (Android 12+) |
| `android/.../CgflixIntroSoundChannel.kt` (novo), `MainActivity.kt` (1 linha), `res/raw/cgflix_intro.wav` | "tum" da abertura, só fora do silencioso/vibrar |
| `cgflix-brand/som/gerar_tum.py` (novo) | gera o `cgflix_intro.wav` (som procedural, sem direitos de terceiros) |
| `docs/prints/` | quadros da abertura |

**Em alta no Brasil**: o app lê `GET <servidor>/cgflix/emalta.json` no formato
`{"titulo": "...", "itens": [{"id": "<id do Jellyfin>", "nome": "...", "tipo": "Movie|Series"}]}` (já ordenado). Se o arquivo
não existir, usa a coleção do Jellyfin chamada "Em alta no Brasil"; se nenhum dos dois existir, a linha some. Vale 1 h no aparelho.

## Etapa 1C — remodelagem (versão 1.1.0, versionCode 300)

Pedido do dono depois do 1.0.0 (200) no motorola edge 70: busca sem repetição, navegação sem nada duplicado e visual
mais polido e integrado ao Android. Ordem de serviço em `docs/ORDEM_1C.md`.

| Arquivo | Mudança |
|---|---|
| `pubspec.yaml` | `version: 1.1.0+300`; fonte **Inter** (pesos 400–800) |
| `assets/fonts/Inter-*.ttf`, `Inter-LICENSE.txt` (novos) | Inter 4.1 (licença OFL, igual ao site) |
| `lib/cgflix/search/cgflix_search_grouping.dart` (novo) | agrupa a busca: títulos por tmdb/imdb/tvdb/guid `plex://` ou título normalizado + ano + tipo (IDs conflitantes nunca juntam); pessoas pelo nome; fonte preferida = CGFLIX → progresso → resolução → ordem; ordem Títulos → Pessoas → Coleções |
| `lib/cgflix/search/cgflix_sources.dart` (novo) | seletor "Disponível em N servidores" na página do título; filmografia da pessoa juntando todos os servidores |
| `lib/cgflix/search/cgflix_search_extras.dart` (novo) | buscas recentes, "Pedir" (Seerr) quando não acha nada, esqueleto no lugar do círculo |
| `lib/screens/search_screen.dart` | ganchos: resultado unificado, sem nome de servidor, histórico, Pedir, esqueleto, sem barra de título no celular |
| `lib/services/jellyfin_client/parts/browse.dart` | busca pede `ProviderIds` (1 linha) |
| `lib/screens/media_detail_screen.dart` | 1 linha: seletor de servidor acima da sinopse |
| `lib/screens/actor_media_screen.dart` | gancho: filmografia de todos os servidores |
| `lib/screens/catalog_search_screen.dart` | `initialQuery` (o "Pedir" abre com o termo) |
| `lib/cgflix/cgflix_navigation.dart` | barra compacta só com ícones (60 dp, sem rótulos, TalkBack/dica com o nome), translúcida com desfoque, indicador roxo, háptico; `CgflixAboveNavBar` |
| `lib/screens/main_screen.dart` | ganchos: `extendBody` e a barra do CGFLIX no celular; Baixados termina acima da barra |
| `lib/cgflix/home/cgflix_home_screen.dart` | sem avatar; chips filtram a própria Início (× volta a Tudo, troca de 300 ms); topo some ao rolar para baixo, sobre gradiente |
| `lib/cgflix/home/cgflix_home_logic.dart`, `cgflix_home_repository.dart`, `cgflix_jellyfin_queries.dart` | consultas com filtro de biblioteca (`ParentId`), cache separado por filtro |
| `lib/cgflix/cgflix_you_screen.dart` | respeita a barra translúcida |
| `lib/cgflix/cgflix_theme.dart` (novo), `lib/theme/mono_theme.dart` (1 linha), `lib/main.dart` (1 linha) | Inter, cores do site no modo OLED (`#07060a`/`#120e1a`), transições 300/250 ms ease-out no Android, barras do sistema transparentes (ponta a ponta) |
| `lib/cgflix/home/cgflix_actions.dart` | háptico leve ao tocar "Assistir" |
| `test/cgflix/*`, `test/providers/theme_provider_test.dart` | testes do agrupamento, do filtro, da barra e do histórico; fundo OLED = `#07060a` |

**Voltar preditivo**: as transições já acompanham o gesto quando ele for ligado, mas o `android:enableOnBackInvokedCallback`
ficou **desligado**: com ele, o Android deixa de entregar a tecla VOLTAR do controle remoto como tecla, e a navegação da TV
do upstream depende disso. Fica para a 1D, com teste numa TV box.

## Como gerar o APK

- **No GitHub**: aba *Actions* → "CGFLIX Android" → artifact `cgflix-apk` (`cgflix-arm64-v8a.apk` serve para quase todos os celulares e TV box atuais; `armeabi-v7a` para aparelhos antigos de 32 bits).
- **Release**: criar a tag `v*` (ex.: `git tag v0.1.0 && git push origin v0.1.0`); o `cgflix-release.yml` anexa os APKs à Release.
- **Assinatura própria (depois)**: cadastrar os secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`. Sem eles, o APK sai assinado com a chave de debug (instala, mas **trocar a chave depois obriga a desinstalar o app**; defina o keystore antes de distribuir de verdade).
- **Local**: Flutter 3.47.1, JDK 21, Android SDK/NDK (ver `android/app/build.gradle.kts`) e `flutter build apk --release --split-per-abi`.

## Como sincronizar com o upstream

```bash
git remote add upstream https://github.com/edde746/plezy.git   # uma vez
git fetch upstream
git checkout -b sync/upstream-AAAA-MM-DD main
git merge upstream/main        # resolver conflitos mantendo os ganchos CGFLIX
flutter pub get && flutter analyze && flutter test
```

Abrir PR para o `main` **deste** repositório (nunca para o upstream). Os conflitos esperados são só nos arquivos da tabela acima.
Ao resolver, conferir `grep -rn "CGFLIX" lib android .github`.

## Próximos passos sugeridos

1. Nome "CGFLIX" também dentro do app (título, tela "Sobre") e logo na tela de entrada; textos em PT para o que ainda estiver em inglês.
2. Selos **Dublado / Legendado** nos cartões e na tela de detalhes (a partir das faixas de áudio/legenda).
3. **Pedidos (Seerr)** com login por Quick Connect.
4. Aviso claro em PT quando o servidor recusar o play por limite de **2 telas** (StreamLimiter).
5. **Atualização do app pelo nosso servidor** (o verificador de atualização do upstream fica desligado: não definimos `ENABLE_UPDATE_CHECK`).
6. Keystore próprio nos secrets; build do Windows a partir do mesmo código; iPhone depois.
