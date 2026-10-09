// Seções recolhíveis das Configurações (estilo "omakase": começa tudo fechado,
// o usuário abre só o que precisa). Fica aqui para os arquivos do upstream só
// ganharem ganchos pequenos: o [SettingsGroup] consulta este escopo.
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/mono_tokens.dart';
import '../widgets/app_icon.dart';
import '../widgets/focusable_list_tile.dart';

/// Liga (ou desliga) o modo recolhível para os [SettingsGroup] com título que
/// estiverem abaixo dele. Sem escopo, o grupo continua igual ao original.
class CgflixCollapsibleScope extends InheritedWidget {
  final bool enabled;

  const CgflixCollapsibleScope({super.key, this.enabled = true, required super.child});

  static bool isEnabled(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CgflixCollapsibleScope>()?.enabled ?? false;

  @override
  bool updateShouldNotify(CgflixCollapsibleScope oldWidget) => oldWidget.enabled != enabled;
}

/// Cartão que abre e fecha. O conteúdo só é construído enquanto está aberto.
class CgflixCollapsibleCard extends StatefulWidget {
  final String title;
  final bool initiallyExpanded;
  final Widget child;

  /// Só para testes das telas de Configurações que procuram opções dentro de seções fechadas.
  @visibleForTesting
  static bool debugExpandAll = false;

  const CgflixCollapsibleCard({super.key, required this.title, this.initiallyExpanded = false, required this.child});

  @override
  State<CgflixCollapsibleCard> createState() => _CgflixCollapsibleCardState();
}

class _CgflixCollapsibleCardState extends State<CgflixCollapsibleCard> {
  late bool _expanded = widget.initiallyExpanded || CgflixCollapsibleCard.debugExpandAll;

  @override
  Widget build(BuildContext context) {
    final t = tokens(context);
    void toggle() => setState(() => _expanded = !_expanded);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: t.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusLg)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FocusableListTile(
              title: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              trailing: AppIcon(_expanded ? Symbols.expand_less_rounded : Symbols.expand_more_rounded, fill: 1),
              onTap: toggle,
            ),
            if (_expanded) widget.child,
            if (_expanded) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
