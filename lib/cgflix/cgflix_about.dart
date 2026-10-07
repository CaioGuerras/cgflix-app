// Peças que são só do CGFLIX: dedicatória (Sobre, abertura, menu do usuário e rodapé da
// Início) e créditos ao Plezy.
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../services/settings_service.dart';
import '../widgets/app_icon.dart';
import 'cgflix_style.dart';

const cgflixDedicationText = 'Feito com amor, para Isis e Heitor';

/// Configurações › Avançado › "Mostrar dedicatória" (padrão ligado). No Sobre ela fica sempre.
const cgflixShowDedicationPref = BoolPref('cgflix_show_dedication', defaultValue: true);

/// Coração roxo (Isis) e verde (Heitor).
class CgflixDedicationHearts extends StatelessWidget {
  const CgflixDedicationHearts({super.key, this.size = 22, this.spacing = 8});
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(Symbols.favorite_rounded, fill: 1, color: CgflixColors.accent, size: size),
        SizedBox(width: spacing),
        AppIcon(Symbols.favorite_rounded, fill: 1, color: CgflixColors.dedication, size: size),
      ],
    ),
  );
}

/// Dedicatória, centralizada abaixo da versão: coração roxo e coração verde.
class CgflixDedication extends StatelessWidget {
  const CgflixDedication({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(cgflixDedicationText, style: style, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        const CgflixDedicationHearts(),
      ],
    );
  }
}

/// Dedicatória numa linha só, discreta (menu do usuário e rodapé da Início). Some quando
/// "Mostrar dedicatória" está desligado.
class CgflixDedicationLine extends StatelessWidget {
  const CgflixDedicationLine({super.key, this.center = false});
  final bool center;

  @override
  Widget build(BuildContext context) {
    final service = SettingsService.instanceOrNull;
    final line = Semantics(
      label: '$cgflixDedicationText, com um coração roxo e um verde',
      excludeSemantics: true,
      child: Wrap(
        alignment: center ? WrapAlignment.center : WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Text(
            cgflixDedicationText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: CgflixColors.textMuted, letterSpacing: 0.2),
          ),
          const CgflixDedicationHearts(size: 14, spacing: 4),
        ],
      ),
    );
    if (service == null) return line;
    return ValueListenableBuilder<bool>(
      valueListenable: service.listenable(cgflixShowDedicationPref),
      builder: (context, show, _) => show ? line : const SizedBox.shrink(),
    );
  }
}

/// Dedicatória na abertura do app: aparece devagar (600 ms) embaixo do emblema, sem
/// segurar a partida (não entra na espera da abertura). Respeita "Mostrar dedicatória".
class CgflixIntroDedication extends StatelessWidget {
  const CgflixIntroDedication({super.key});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: CgflixMotion.crossFade,
    curve: CgflixMotion.curve,
    builder: (context, t, child) => Opacity(opacity: t, child: child),
    child: const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: CgflixDedicationLine(center: true)),
  );
}

/// Créditos ao projeto original (GPL-3.0). Só aparecem no Sobre e no README.
class CgflixCredits extends StatelessWidget {
  const CgflixCredits({super.key});

  @override
  Widget build(BuildContext context) => Text(
    'O CGFLIX é baseado no Plezy (github.com/edde746/plezy), software livre sob a licença GPL-3.0.',
    style: Theme.of(context).textTheme.bodySmall,
    textAlign: TextAlign.center,
  );
}
