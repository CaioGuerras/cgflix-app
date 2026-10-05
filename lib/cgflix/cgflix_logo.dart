// Emblema CGFLIX ("C com play") usado nas telas de marca (splash do Flutter,
// entrada, Sobre). Arquivo próprio para os arquivos do upstream só chamarem daqui.
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Emblema do app. O SVG é o de `cgflix-brand/` sem o filtro de brilho
/// (o flutter_svg não renderiza filtros).
class CgflixEmblem extends StatelessWidget {
  final double size;

  const CgflixEmblem({super.key, required this.size});

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/cgflix_emblema.svg', width: size, height: size, semanticsLabel: 'CGFLIX');
}
