import 'package:faker/faker.dart';
import 'package:flutter_tdd_bdd_solid_clean_arch/data/http/http.dart';
import 'package:flutter_tdd_bdd_solid_clean_arch/data/usecases/usecases.dart';
import 'package:flutter_tdd_bdd_solid_clean_arch/domain/errors/errors.dart';
import 'package:flutter_tdd_bdd_solid_clean_arch/domain/usecases/usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  // sut => system under test
  late RemoteAuthentication sut;
  late HttpClientSpy httpClient;
  late String url;
  late AuthenticationParams params;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      secret: faker.internet.password(),
    );
  });

  test(
    'Should call HttpClient with the correct values',
    () async {
      when(
        () => httpClient.request(
          url: any(named: 'url'),
          method: any(named: 'method'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {
        return;
      });

      await sut.auth((params));

      verify(
        () => httpClient.request(
          url: url,
          method: 'post',
          body: {
            'email': params.email,
            'password': params.secret,
          },
        ),
      );
    },
  );

  test(
    'Should throw UnexpectedError if HttpClient return 400',
    () async {
      when(
        () => httpClient.request(
          url: any(named: 'url'),
          method: any(named: 'method'),
          body: any(named: 'body'),
        ),
      ).thenThrow((HttpError.badRequest));

      final future = sut.auth((params));

      expect(future, throwsA(DomainError.unexpected));
    },
  );
  test(
    'Should throw UnexpectedError if HttpClient return 404',
    () async {
      when(
        () => httpClient.request(
          url: any(named: 'url'),
          method: any(named: 'method'),
          body: any(named: 'body'),
        ),
      ).thenThrow((HttpError.notFound));

      final future = sut.auth((params));

      expect(future, throwsA(DomainError.unexpected));
    },
  );
  test(
    'Should throw UnexpectedError if HttpClient return 500',
    () async {
      when(
        () => httpClient.request(
          url: any(named: 'url'),
          method: any(named: 'method'),
          body: any(named: 'body'),
        ),
      ).thenThrow((HttpError.serverError));

      final future = sut.auth((params));

      expect(future, throwsA(DomainError.unexpected));
    },
  );
  test(
    'Should throw InvalidCredentialError if HttpClient return 401',
    () async {
      when(
        () => httpClient.request(
          url: any(named: 'url'),
          method: any(named: 'method'),
          body: any(named: 'body'),
        ),
      ).thenThrow((HttpError.unAuthorised));

      final future = sut.auth((params));

      expect(future, throwsA(DomainError.invalidCredentials));
    },
  );
}
