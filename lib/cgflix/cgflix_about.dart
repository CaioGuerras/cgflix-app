// Peças da tela "Sobre" que são só do CGFLIX (dedicatória e créditos ao Plezy).
import 'package:flutter/material.dart';

/// Dedicatória, centralizada abaixo da versão: coração roxo e coração verde.
class CgflixDedication extends StatelessWidget {
  const CgflixDedication({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Feito com amor, para Isis e Heitor', style: style, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Color(0xFFA855F7), size: 22),
            SizedBox(width: 8),
            Icon(Icons.favorite, color: Color(0xFF22C55E), size: 22),
          ],
        ),
      ],
    );
  }
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
