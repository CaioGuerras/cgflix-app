// Identidade visual e movimento do CGFLIX (Etapa 1B). Um lugar só para cores,
// curvas e durações, para todas as telas novas andarem no mesmo ritmo.
import 'package:flutter/animation.dart';

abstract final class CgflixColors {
  /// Fundo preto OLED.
  static const background = Color(0xFF07060A);

  /// Superfícies (cartões, painéis, chips).
  static const surface = Color(0xFF120E1A);
  static const surfaceHigh = Color(0xFF1C1626);

  /// Roxo de destaque e o tom "pressionado".
  static const accent = Color(0xFFA855F7);
  static const accentPressed = Color(0xFF9333EA);
  static const lilac = Color(0xFFC084FC);

  /// Verde: só na dedicatória.
  static const dedication = Color(0xFF22C55E);

  static const textMuted = Color(0xB3FFFFFF);
}

/// Movimento: tudo entre 250 e 350 ms, sempre com curva ease-out (nada de corte seco).
abstract final class CgflixMotion {
  static const fast = Duration(milliseconds: 250);
  static const medium = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 350);

  /// Troca de filtro na Início: some e volta, 150 ms cada (300 ms no total).
  static const filterFade = Duration(milliseconds: 150);

  /// Troca cruzada do destaque (fundo + logo).
  static const crossFade = Duration(milliseconds: 600);

  static const curve = Curves.easeOutCubic;
}
