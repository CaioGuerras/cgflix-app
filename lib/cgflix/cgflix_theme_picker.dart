// Escolha de tema do CGFLIX (versão 1.4.0): Configurações → Aparência → Tema.
// Isis (escuro, roxo) / Heitor (claro, verde) / Automático (segue o aparelho). Guarda na
// preferência `themeMode` do upstream (ver `cgflixMaterialThemeMode`), que o ThemeProvider já
// observa: a troca vale na hora, sem reiniciar. Na TV a escolha não aparece (TV fica Isis).
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../screens/settings/settings_utils.dart';
import '../services/settings_service.dart' as settings;
import '../widgets/setting_tile.dart';

/// Opções na ordem da tela (padrão: Isis).
const cgflixThemeChoices = [settings.ThemeMode.oled, settings.ThemeMode.light, settings.ThemeMode.system];

/// Nome curto do tema (o `dark` antigo do upstream conta como Isis).
String cgflixThemeName(settings.ThemeMode mode) => switch (mode) {
  settings.ThemeMode.light => 'Heitor',
  settings.ThemeMode.system => 'Automático',
  settings.ThemeMode.dark || settings.ThemeMode.oled => 'Isis',
};

/// O que o tema é, em palavras simples (também lido pelo leitor de tela).
String cgflixThemeDescription(settings.ThemeMode mode) => switch (mode) {
  settings.ThemeMode.light => 'Claro, verde',
  settings.ThemeMode.system => 'Segue o modo claro/escuro do aparelho',
  settings.ThemeMode.dark || settings.ThemeMode.oled => 'Escuro, roxo',
};

/// Rótulo completo: "Isis (escuro, roxo)".
String cgflixThemeLabel(settings.ThemeMode mode) => switch (mode) {
  settings.ThemeMode.light => 'Heitor (claro, verde)',
  settings.ThemeMode.system => 'Automático (segue o aparelho)',
  settings.ThemeMode.dark || settings.ThemeMode.oled => 'Isis (escuro, roxo)',
};

/// Linha "Tema" das Configurações → Aparência.
class CgflixThemeSelector extends StatelessWidget {
  const CgflixThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingSelectionTile<settings.ThemeMode>(
      key: const ValueKey('cgflix-tema'),
      pref: settings.SettingsService.themeMode,
      icon: Symbols.palette_rounded,
      title: 'Tema',
      subtitleBuilder: cgflixThemeLabel,
      options: [
        for (final mode in cgflixThemeChoices)
          DialogOption(value: mode, title: cgflixThemeName(mode), subtitle: cgflixThemeDescription(mode)),
      ],
    );
  }
}
