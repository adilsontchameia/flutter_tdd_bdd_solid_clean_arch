import 'dart:convert';

import 'package:dio/dio.dart';

import '../data/http/http.dart';

class HttpAdapter implements HttpClient {
  final Dio client;
  HttpAdapter(this.client);

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

    try {
      final response = await client.post(
        url,
        options: Options(headers: headers),
        data: jsonBody,
      );

      return _handleResponse(response);
    } catch (error) {
      rethrow;
    }
  }

  Map? _handleResponse(Response response) {
    if (response.statusCode == 200) {
      if (response.data == null || response.data.toString().isEmpty) {
        return null;
      }
      return jsonDecode(response.data);
    } else if (response.statusCode == 204) {
      return null;
    } else if (response.statusCode == 400) {
      throw HttpError.badRequest;
    } else if (response.statusCode == 401) {
      throw HttpError.unAuthorised;
    } else {
      throw HttpError.serverError;
    }
  }
}
