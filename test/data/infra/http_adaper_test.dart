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
    Map body = const {},
  }) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    await _client.post(url, options: Options(headers: headers));
  }
}

void main() {
  //For post only
  group('post', () {
    test('Should call post with correct values', () async {
      final client = ClientSpy();
      final sut = HttpAdapter(client);
      final url = faker.internet.httpUrl();

      when(() => client.post(url, options: any(named: 'options'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: url),
          statusCode: 200,
        ),
      );

      await sut.request(url: url, method: 'post');

      verifyNever(
        () => client.post(
          url,
          options: Options(
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json',
            },
          ),
        ),
      );
    });
  });
}
