// Aba "Você" (celular): quem está usando, trocar perfil/usuário, Configurações e Sobre.
// O resto das opções continua dentro de Configurações, como na Etapa 1A.
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../i18n/strings.g.dart';
import '../navigation/settings_shortcut.dart';
import '../profiles/active_profile_provider.dart';
import '../profiles/profile_avatar.dart';
import '../screens/profile/profile_switch_screen.dart';
import '../screens/settings/about_screen.dart';
import '../widgets/app_icon.dart';
import 'cgflix_logo.dart';
import 'cgflix_style.dart';

class CgflixYouScreen extends StatelessWidget {
  const CgflixYouScreen({super.key});

  void _push(BuildContext context, Route<void> route, {bool root = false}) {
    Navigator.of(context, rootNavigator: root).push(route);
  }

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ActiveProfileProvider>();
    final active = profiles.active;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: CgflixColors.background,
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    if (active != null)
                      ProfileAvatar(profile: active, size: 64, avatarUrl: profiles.avatarUrlFor(active.id))
                    else
                      const AppIcon(Symbols.account_circle_rounded, fill: 1, size: 64),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            active?.displayName ?? 'Você',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profiles.profiles.length > 1
                                ? '${profiles.profiles.length} perfis neste aparelho'
                                : 'Perfil deste aparelho',
                            style: theme.textTheme.bodyMedium?.copyWith(color: CgflixColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList.list(
              children: [
                _YouTile(
                  icon: Symbols.switch_account_rounded,
                  title: 'Trocar perfil ou usuário',
                  subtitle: 'Escolha quem está assistindo ou entre com outra conta',
                  onTap: () =>
                      _push(context, MaterialPageRoute(builder: (_) => const ProfileSwitchScreen()), root: true),
                ),
                _YouTile(
                  icon: Symbols.settings_rounded,
                  title: t.common.settings,
                  subtitle: 'Idioma, aparência, reprodução, downloads',
                  onTap: () => _push(context, buildSettingsRoute()),
                ),
                _YouTile(
                  icon: Symbols.info_rounded,
                  title: t.settings.about,
                  subtitle: 'Versão, dedicatória e créditos',
                  onTap: () => _push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                ),
                const SizedBox(height: 40),
                const Center(child: Opacity(opacity: 0.5, child: CgflixEmblem(size: 40))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YouTile extends StatelessWidget {
  const _YouTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: CgflixColors.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: AppIcon(icon, fill: 1, color: CgflixColors.lilac),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: const TextStyle(color: CgflixColors.textMuted)),
          trailing: const AppIcon(Symbols.chevron_right_rounded, fill: 1),
          onTap: onTap,
        ),
      ),
    );
  }
}
