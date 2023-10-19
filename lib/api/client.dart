import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpClient {
  final String accessToken;

  HttpClient({required this.accessToken});

  Future<Map<String, dynamic>?> makeRequest({
    required String url,
    bool headers = true,
    Map<String, dynamic>? query,
  }) async {
    try {
      String result = (await http.get(
              _parseUrl(
                url,
                query: query,
              ),
              headers:
                  headers ? {'Authorization': 'Bearer $accessToken'} : null))
          .body;
      return (jsonDecode(result) as Map<String, dynamic>?)?['response'];
    } catch (e) {
      return null;
    }
  }

  Future<String> requestBody({required String url}) async {
    return (await http.get(_parseUrl(url))).body;
  }

  Uri _parseUrl(
    String url, {
    Map<String, dynamic>? query,
  }) {
    return Uri.parse(Uri.encodeFull(url)).replace(queryParameters: query);
  }
}
