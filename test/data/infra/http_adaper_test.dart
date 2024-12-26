import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_tdd_bdd_solid_clean_arch/data/http/http.dart';
import 'package:flutter_tdd_bdd_solid_clean_arch/infra/infra.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class ClientSpy extends Mock implements Dio {}

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
      await sut.request(url: url, method: 'get');

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
    test('Should return BadRequestError if post returns 400', () async {
      mockResponse(statusCode: 400);

      expect(
        () async => await sut.request(url: url, method: 'post'),
        throwsA(
            isA<HttpError>().having((e) => e, 'type', HttpError.badRequest)),
      );
    });

    test('Should return BadRequestError if post returns 400 witout data',
        () async {
      mockResponse(statusCode: 400, data: '');

      expect(
        () async => await sut.request(url: url, method: 'post'),
        throwsA(
            isA<HttpError>().having((e) => e, 'type', HttpError.badRequest)),
      );
    });
    test('Should return UnAuthorisedError if post returns 401', () async {
      mockResponse(statusCode: 401);

      expect(
        () async => await sut.request(url: url, method: 'post'),
        throwsA(
            isA<HttpError>().having((e) => e, 'type', HttpError.unAuthorised)),
      );
    });
    test('Should return ForbidenError if post returns 403', () async {
      mockResponse(statusCode: 403);

      expect(
        () async => await sut.request(url: url, method: 'post'),
        throwsA(isA<HttpError>().having((e) => e, 'type', HttpError.forbiden)),
      );
    });
    test('Should return NotFoundError if post returns 404', () async {
      mockResponse(statusCode: 404);

      expect(
        () async => await sut.request(url: url, method: 'post'),
        throwsA(isA<HttpError>().having((e) => e, 'type', HttpError.notFound)),
      );
    });
    test('Should return ServerError if post returns 500 witout data', () async {
      mockResponse(statusCode: 500);

      expect(
        () async => await sut.request(url: url, method: 'post'),
        throwsA(
            isA<HttpError>().having((e) => e, 'type', HttpError.serverError)),
      );
    });
  });
  group('shared', () {
    test('Should throw server error if invalid method is provided', () async {
      expect(
        () async => await sut.request(url: url, method: 'invalid_method'),
        throwsA(
            isA<HttpError>().having((e) => e, 'type', HttpError.serverError)),
      );
    });
  });
}
