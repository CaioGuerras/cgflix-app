// Itens que saíram da tela principal e ficam em Configurações > Avançado:
// Assistir juntos, Controle remoto, as opções do mpv e "Mostrar dedicatória".
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../screens/companion_remote/mobile_remote_screen.dart';
import '../screens/settings/mpv_config_screen.dart';
import '../utils/platform_detector.dart';
import '../watch_together/watch_together.dart';
import '../widgets/companion_remote/remote_session_dialog.dart';
import '../widgets/setting_tile.dart';
import '../widgets/settings_section.dart';
import 'cgflix_about.dart';

/// Grupo com os recursos avançados que não aparecem mais na Início.
class CgflixAdvancedFeatures extends StatelessWidget {
  const CgflixAdvancedFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformDetector.shouldActAsRemoteHost(context);
    void openRemote() {
      if (isDesktop) {
        RemoteSessionDialog.show(context);
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileRemoteScreen()));
      }
    }

    return SettingsGroup(
      children: [
        SettingNavigationTile(
          icon: Symbols.group_rounded,
          title: 'Assistir juntos',
          subtitle: 'Assista ao mesmo filme ou série ao mesmo tempo que outra pessoa, cada um no seu aparelho.',
          destinationBuilder: (_) => const WatchTogetherScreen(),
        ),
        SettingNavigationTile(
          icon: Symbols.phone_android_rounded,
          title: 'Controle remoto',
          // Explica o limite: não é um controle universal de TV.
          subtitle:
              'Controla OUTRO aparelho com o CGFLIX aberto, na mesma rede Wi-Fi e na mesma conta. '
              'Não reconhece TV comum.',
          onTap: openRemote,
        ),
        SettingNavigationTile(
          icon: Symbols.tune_rounded,
          title: 'Opções do mpv',
          subtitle: 'Ajustes técnicos do player. Só mexa se souber o que está fazendo.',
          destinationBuilder: (_) => const MpvConfigScreen(),
        ),
        const SettingSwitchTile(
          pref: cgflixShowDedicationPref,
          icon: Symbols.favorite_rounded,
          title: 'Mostrar dedicatória',
          subtitle: 'Na abertura, no menu do usuário e no fim da Início. No Sobre ela aparece sempre.',
        ),
      ],
    );
  }
}
