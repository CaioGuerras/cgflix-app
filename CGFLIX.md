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
