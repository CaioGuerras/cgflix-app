// Numeração própria do CGFLIX (a do Plezy ficou para trás na Etapa 1B).
// A versão real vem do pubspec.yaml (`version: 1.0.0+200`); aqui só o texto do Sobre.

/// Texto da versão no Sobre: "CGFLIX 1.0.0". Sem versão (ainda carregando), só "CGFLIX".
String cgflixVersionLabel(String version) => version.isEmpty ? 'CGFLIX' : 'CGFLIX $version';

/// Menor versionCode aceito pela Play: a Etapa 1A publicou o 152, então daqui para frente
/// o código precisa ser maior (a Etapa 1B começa no 200).
const int cgflixMinVersionCode = 200;
