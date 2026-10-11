// CGFLIX (1.5.0, acabamento): avisos (snackbars) nas cores do tema. O upstream pintava sucesso de
// verde e erro de vermelho fixos (fora do esquema e com contraste fraco no Heitor, onde o texto do
// aviso é quase branco). Agora: erro = `error`/`onError` do tema; sucesso = aviso normal do tema.
import 'package:flutter/material.dart';

import 'cgflix_palette.dart';

/// Cores (fundo, texto) do aviso a partir da cor que o upstream pediu. Nulo = a do tema.
(Color?, Color?) cgflixSnackBarColors(BuildContext context, Color? upstream) {
  final scheme = Theme.of(context).colorScheme;
  if (identical(upstream, Colors.red)) return (scheme.error, scheme.onError);
  if (identical(upstream, Colors.green)) return (null, null);
  return (upstream, null);
}

/// Destaque do player (sempre escuro): o lilás do CGFLIX no lugar do âmbar do upstream (chaves
/// ligadas, item escolhido, timer ativo).
const cgflixPlayerAccent = Color(0xFFC084FC);

/// Cores dos estados de download (o upstream usava laranja/azul/âmbar/verde/vermelho soltos, quase
/// invisíveis no fundo claro do Heitor). Tudo da paleta do tema.
class CgflixStatusColors {
  const CgflixStatusColors({required this.active, required this.idle, required this.done, required this.failed});
  final Color active;
  final Color idle;
  final Color done;
  final Color failed;

  static CgflixStatusColors of(BuildContext context) {
    final palette = CgflixPalette.of(context);
    return CgflixStatusColors(
      active: palette.accent,
      idle: palette.textMuted,
      done: palette.success,
      failed: palette.danger,
    );
  }
}
