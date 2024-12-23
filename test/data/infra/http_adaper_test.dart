import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class ClientSpy extends Mock implements Dio {}

class HttpAdapter {
  final Dio _client;
  HttpAdapter(this._client);
  Future<void> request({
    required String url,
    required String method,
    Map? data,
  }) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    final jsonBody = data != null ? jsonEncode(data) : null;
    await _client.post(
      url,
      options: Options(
        headers: headers,
      ),
      data: jsonBody,
    );
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
  //For post only
  group('post', () {
    test('Should call post with correct values', () async {
      when(
        () => client.post(
          url,
          options: any(named: 'options'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: url),
          statusCode: 200,
        ),
      );

      await sut.request(
        url: url,
        method: 'post',
        data: {'any_key': 'any_value'},
      );

      verifyNever(
        () => client.post(
          url,
          options: Options(
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json',
            },
          ),
          data: {'any_key': 'any_value'},
        ),
      );
    });

    test('Should call post without body (data)', () async {
      when(
        () => client.post(any(), options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: url),
          statusCode: 200,
        ),
      );

      await sut.request(url: url, method: 'post');

      verifyNever(
        () => client.post(url,
            options: Options(headers: {
              'content-type': 'application/json',
              'accept': 'application/json',
            })),
      );
    });
  });
}
