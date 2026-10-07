// CGFLIX: consultas da Início direto no Jellyfin. É um `part` do jellyfin_client.dart
// (gancho de 1 linha lá) para usar o HTTP e o mapeamento do cliente sem mexer neles.
part of '../../services/jellyfin_client.dart';

extension CgflixJellyfinQueries on JellyfinClient {
  /// Usuário dono da sessão (para separar o cache do aparelho por conta).
  String get cgflixUserId => connection.userId;

  /// `GET /Items` com os campos que os cartões e a prévia usam. [params] vence os padrões.
  /// Devolve o JSON cru (vai para o cache do aparelho); [cgflixMapItems] converte.
  Future<List<Map<String, dynamic>>> cgflixFetchRawItems(Map<String, String> params, {Duration? timeout}) async {
    final query = <String, dynamic>{
      'UserId': connection.userId,
      'Recursive': 'true',
      'Fields': '$_hubRowFields,Genres,ChildCount,RecursiveItemCount',
      'EnableUserData': 'true',
      ...jellyfinImageQueryParameters,
      ...params,
    };
    final response = await _http.get('/Items', queryParameters: query, timeout: timeout ?? const Duration(seconds: 12));
    throwIfHttpError(response);
    return _itemsArray(response.data);
  }

  List<MediaItem> cgflixMapItems(Iterable<Map<String, dynamic>> raw) => _mapItems(raw);

  /// Gêneros de filmes e séries do usuário (já vêm em português do servidor).
  /// Com [parentId], só os da biblioteca (chip ativo na Início).
  Future<List<Map<String, dynamic>>> cgflixFetchRawGenres({String? parentId, String? itemTypes}) async {
    final response = await _http.get(
      '/Genres',
      queryParameters: {
        'UserId': connection.userId,
        'IncludeItemTypes': itemTypes ?? 'Movie,Series',
        'ParentId': ?parentId,
        'Recursive': 'true',
        'SortBy': 'SortName',
        'Fields': 'ItemCounts',
        'EnableImages': 'false',
      },
      timeout: const Duration(seconds: 12),
    );
    throwIfHttpError(response);
    return _itemsArray(response.data);
  }

  /// JSON servido pelo próprio servidor do CGFLIX (ex.: `/cgflix/emalta.json`). Aceita
  /// corpo já decodificado ou texto. Erros de rede/HTTP sobem para quem chamou.
  Future<Object?> cgflixGetJson(String path) async {
    final response = await _http.get(path, timeout: const Duration(seconds: 8), allowEndpointFailover: false);
    throwIfHttpError(response);
    final data = response.data;
    if (data is String) return data.trim().isEmpty ? null : jsonDecode(data);
    return data;
  }
}
