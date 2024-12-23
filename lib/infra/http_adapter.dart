import 'dart:convert';

import 'package:dio/dio.dart';

import '../data/http/http.dart';

class HttpAdapter implements HttpClient {
  final Dio _client;
  HttpAdapter(this._client);

  @override
  Future<Map?> request({
    required String url,
    required String method,
    Map? data,
  }) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };

    final jsonBody = data != null ? jsonEncode(data) : null;
    final response = await _client.post(
      url,
      options: Options(headers: headers),
      data: jsonBody,
    );

    if (response.data == null || response.data == '') {
      return null;
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      return null;
    }
  }
}
