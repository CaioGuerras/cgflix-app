// Numeração própria do CGFLIX (a do Plezy ficou para trás na Etapa 1B).
// A versão real vem do pubspec.yaml (`version: 1.1.0+300` na Etapa 1C); aqui só o texto do Sobre.

/// Texto da versão no Sobre: "CGFLIX 1.0.0". Sem versão (ainda carregando), só "CGFLIX".
String cgflixVersionLabel(String version) => version.isEmpty ? 'CGFLIX' : 'CGFLIX $version';
