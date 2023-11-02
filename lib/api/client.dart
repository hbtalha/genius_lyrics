import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpClient {
  final String accessToken;

  HttpClient({required this.accessToken});

  Future<Map<String, dynamic>?> makeRequest({
    required String url,
    bool headers = true,
    Map<String, String>? query,
  }) async {
    try {
      String result = (await http.get(
              parseUrl(
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

  static Future<String> requestBody({required String url}) async {
    return (await http.get(HttpClient.parseUrl(url))).body;
  }

  static Uri parseUrl(
    String url, {
    Map<String, String>? query,
  }) {
    return Uri.parse(Uri.encodeFull(url)).replace(queryParameters: query);
  }
}
