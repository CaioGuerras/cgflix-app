# CGFLIX — o que mudou em relação ao Plezy

O CGFLIX é um fork do [Plezy](https://github.com/edde746/plezy) (GPL-3.0). A regra é **diferença mínima**: tudo que é nosso
fica em arquivos próprios e os arquivos do upstream recebem só ganchos de uma linha, para puxar as atualizações sem conflito.
Licença e créditos do Plezy continuam no `LICENSE`, no README e na tela "Sobre".

## Etapa 0 — arquivos alterados/criados

| Arquivo | Mudança |
|---|---|
| `lib/cgflix/cgflix_defaults.dart` (novo) | URL sugerida `https://netflix.docaio.com.br` e regra do idioma padrão (PT quando o aparelho está num idioma que o app não traduz) |
| `lib/screens/settings/add_jellyfin_screen.dart` | campo de servidor Jellyfin já vem preenchido com a URL sugerida (editável; Emby e Plex não mudam) |
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
