import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpClient {
  Future<Map<String, dynamic>?> call({
    required String url,
    Map<String, dynamic>? query,
  }) async {
    try {
      String result = (await http.get(_parseUrl(
        url,
        query: query,
      )))
          .body;
      return (jsonDecode(result) as Map<String, dynamic>?)?['response'];
    } catch (e) {
      return null;
    }
  }

  Uri _parseUrl(
    String url, {
    Map<String, dynamic>? query,
  }) {
    return Uri.parse(Uri.encodeFull(url)).replace(queryParameters: query);
  }
}
