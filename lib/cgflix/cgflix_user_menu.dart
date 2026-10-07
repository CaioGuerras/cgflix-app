// Menu do usuário (Etapa 1D): abre ao tocar no emblema do topo. É o novo lugar do perfil:
// quem está usando, trocar perfil/usuário, Baixados, Configurações, Sobre e Sair.
// Folha inferior com rolagem: cabe também com o celular deitado.
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../i18n/strings.g.dart';
import '../profiles/active_profile_provider.dart';
import '../profiles/profile_avatar.dart';
import '../screens/profile/profile_switch_screen.dart';
import '../screens/profile/profile_teardown.dart';
import '../screens/settings/about_screen.dart';
import '../utils/dialogs.dart';
import '../widgets/app_icon.dart';
import 'cgflix_about.dart';
import 'cgflix_navigation.dart';
import 'cgflix_style.dart';

/// Itens do menu, na ordem em que aparecem (os testes conferem esta lista).
enum CgflixUserMenuItem { switchUser, downloads, settings, about, signOut }

Future<void> showCgflixUserMenu(BuildContext context) async {
  final picked = await showModalBottomSheet<CgflixUserMenuItem>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: CgflixColors.surface,
    constraints: const BoxConstraints(maxWidth: 560),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => const CgflixUserMenuSheet(),
  );
  if (picked == null || !context.mounted) return;
  switch (picked) {
    case CgflixUserMenuItem.switchUser:
      await Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute<void>(builder: (_) => const ProfileSwitchScreen()));
    case CgflixUserMenuItem.downloads:
      await cgflixOpenDownloads(context);
    case CgflixUserMenuItem.settings:
      await cgflixOpenSettings(context);
    case CgflixUserMenuItem.about:
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AboutScreen()));
    case CgflixUserMenuItem.signOut:
      final confirm = await showConfirmDialog(
        context,
        title: t.common.logout,
        message: t.messages.logoutConfirm,
        confirmText: t.common.logout,
        isDestructive: true,
      );
      if (confirm && context.mounted) await logoutAllProfiles(context);
  }
}

/// Conteúdo da folha (separado para os testes montarem sem rota).
class CgflixUserMenuSheet extends StatelessWidget {
  const CgflixUserMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ActiveProfileProvider?>();
    final active = profiles?.active;
    final theme = Theme.of(context);
    void pick(CgflixUserMenuItem item) => Navigator.of(context).pop(item);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quem está usando + dedicatória.
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Row(
                children: [
                  if (active != null)
                    ProfileAvatar(profile: active, size: 52, avatarUrl: profiles!.avatarUrlFor(active.id))
                  else
                    const AppIcon(Symbols.account_circle_rounded, fill: 1, size: 52, color: CgflixColors.lilac),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          active?.displayName ?? 'Você',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const CgflixDedicationLine(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _MenuTile(
              key: const ValueKey('cgflix-menu-switchUser'),
              icon: Symbols.switch_account_rounded,
              title: 'Trocar perfil ou usuário',
              onTap: () => pick(CgflixUserMenuItem.switchUser),
            ),
            _MenuTile(
              key: const ValueKey('cgflix-menu-downloads'),
              icon: Symbols.download_rounded,
              title: 'Baixados',
              onTap: () => pick(CgflixUserMenuItem.downloads),
            ),
            _MenuTile(
              key: const ValueKey('cgflix-menu-settings'),
              icon: Symbols.settings_rounded,
              title: 'Configurações',
              onTap: () => pick(CgflixUserMenuItem.settings),
            ),
            _MenuTile(
              key: const ValueKey('cgflix-menu-about'),
              icon: Symbols.info_rounded,
              title: 'Sobre o CGFLIX',
              onTap: () => pick(CgflixUserMenuItem.about),
            ),
            const Divider(height: 16, color: Color(0x1FFFFFFF)),
            _MenuTile(
              key: const ValueKey('cgflix-menu-signOut'),
              icon: Symbols.logout_rounded,
              title: 'Sair',
              onTap: () => pick(CgflixUserMenuItem.signOut),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({super.key, required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 52,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: AppIcon(icon, fill: 1, color: CgflixColors.lilac),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
