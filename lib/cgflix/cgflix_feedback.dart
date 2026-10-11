// CGFLIX (1.5.0, acabamento): avisos (snackbars) nas cores do tema. O upstream pintava sucesso de
// verde e erro de vermelho fixos (fora do esquema e com contraste fraco no Heitor, onde o texto do
// aviso é quase branco). Agora: erro = `error`/`onError` do tema; sucesso = aviso normal do tema.
import 'package:flutter/material.dart';

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
