// Numeração própria do CGFLIX (a do Plezy ficou para trás na Etapa 1B).
// A versão real vem do pubspec.yaml (`version: 1.5.0+700` no refino 1); aqui só o texto do Sobre.

/// Texto da versão no Sobre, logo abaixo do nome: "Versão 1.5.0" (1.5.0: sem repetir "CGFLIX").
/// Sem versão (ainda carregando), vazio.
String cgflixVersionLabel(String version) => version.isEmpty ? '' : 'Versão $version';
