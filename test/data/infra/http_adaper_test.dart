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

    return jsonDecode(response.data);
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
    test('Should call post with correct values', () async {
      when(
        () => client.post(
          url,
          options: any(named: 'options'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: url)),
      );

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
      when(
        () => client.post(any(), options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: url)),
      );

      await sut.request(url: url, method: 'post');

      verify(() => client.post(
            any(),
            options: any(named: 'options'),
          ));
    });

    test('Should return data if post returns 200', () async {
      when(
        () => client.post(any(), options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response(
          data: jsonEncode({'any_key': 'any_value'}),
          requestOptions: RequestOptions(path: url),
          statusCode: 200,
        ),
      );

      final response = await sut.request(url: url, method: 'post');

      expect(response, {'any_key': 'any_value'});
    });
    test('Should return null if post returns 200 with no data', () async {
      when(
        () => client.post(any(), options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response(
          data: '',
          requestOptions: RequestOptions(path: url),
          statusCode: 200,
        ),
      );

      final response = await sut.request(url: url, method: 'post');

      expect(response, null);
    });

    test('Should return empty map if response data is null', () async {
      when(
        () => client.post(any(), options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response(
          data: null,
          requestOptions: RequestOptions(path: url),
          statusCode: 200,
        ),
      );

      final response = await sut.request(url: url, method: 'post');

      expect(response, {});
    });
  });
}
