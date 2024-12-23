import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_tdd_bdd_solid_clean_arch/data/http/http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class ClientSpy extends Mock implements Dio {}

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

void main() {
  late ClientSpy client;
  late HttpAdapter sut;
  late String url;

  setUp(() {
    client = ClientSpy();
    sut = HttpAdapter(client);
    url = faker.internet.httpUrl();
  });

  group('post', () {
    When mockRequest() => when(
          () => client.post(
            url,
            options: any(named: 'options'),
            data: any(named: 'data'),
          ),
        );

    void mockResponse({required int statusCode, Object? data}) =>
        mockRequest().thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: url),
            data: data,
            statusCode: statusCode,
          ),
        );

    setUp(() {
      mockResponse(statusCode: 200);
    });

    test('Should call post with correct values', () async {
      await sut.request(
        url: url,
        method: 'post',
        data: {'any_key': 'any_value'},
      );

      verify(() => client.post(
            url,
            options: any(named: 'options'),
            data: jsonEncode({'any_key': 'any_value'}),
          ));
    });

    test('Should call post without body (data)', () async {
      await sut.request(url: url, method: 'post');

      verify(() => client.post(
            any(),
            options: any(named: 'options'),
          ));
    });

    test('Should return data if post returnss 200', () async {
      mockResponse(
        statusCode: 200,
        data: jsonEncode({'any_key': 'any_value'}),
      );

      final response = await sut.request(url: url, method: 'post');

      expect(response, {'any_key': 'any_value'});
    });

    test('Should return null if post returns 200 with no data', () async {
      mockResponse(statusCode: 200, data: '');

      final response = await sut.request(url: url, method: 'post');

      expect(response, null);
    });
    test('Should return null if post returns 204', () async {
      mockResponse(statusCode: 204, data: '');

      final response = await sut.request(url: url, method: 'post');

      expect(response, null);
    });
    test('Should return null if post returns 204 with data', () async {
      mockResponse(statusCode: 204);

      final response = await sut.request(url: url, method: 'post');

      expect(response, null);
    });
  });
}
