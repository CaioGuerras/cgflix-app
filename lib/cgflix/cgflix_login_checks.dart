// CGFLIX (1.5.0): mensagens claras no login antes de ir ao servidor. Com campo vazio ou endereço
// torto, o servidor devolvia erro técnico (ou o "Falha ao entrar: ..." com o texto da exceção).

const cgflixLoginMissingMessage = 'Preencha o usuário e a senha.';
const cgflixServerEmptyMessage = 'Digite o endereço do servidor, por exemplo https://seu.servidor.com';
const cgflixServerInvalidMessage =
    'Esse endereço não parece certo. Confira se digitou tudo, por exemplo https://seu.servidor.com';

/// Usuário ou senha vazios. Nulo = pode ir ao servidor. (Os servidores do CGFLIX não têm conta
/// sem senha; o upstream aceitava senha vazia.)
String? cgflixLoginMissing(String username, String password) =>
    username.trim().isEmpty || password.isEmpty ? cgflixLoginMissingMessage : null;

/// Endereço do servidor vazio ou que não tem como ser um endereço (espaço no meio, sem nome,
/// símbolos). Aceita sem `https://` (o app completa) e com porta. Nulo = pode procurar.
String? cgflixServerAddressProblem(Iterable<String> enteredUrls) {
  final urls = enteredUrls.map((u) => u.trim()).where((u) => u.isNotEmpty).toList();
  if (urls.isEmpty) return cgflixServerEmptyMessage;
  for (final url in urls) {
    if (!_looksLikeAddress(url)) return cgflixServerInvalidMessage;
  }
  return null;
}

final _hostChars = RegExp(r'^[A-Za-z0-9._\-~%]+$');

bool _looksLikeAddress(String url) {
  if (url.contains(RegExp(r'\s'))) return false;
  final withScheme = url.contains('://') ? url : 'https://$url';
  final uri = Uri.tryParse(withScheme);
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return false;
  final host = uri.host;
  if (host.isEmpty) return false;
  // IPv6 entre colchetes: o Uri já validou.
  if (withScheme.contains('[')) return true;
  return _hostChars.hasMatch(host) && !host.startsWith('.') && !host.endsWith('..');
}
