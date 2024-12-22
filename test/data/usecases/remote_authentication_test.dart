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

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
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

      final paramns = AuthenticationParams(
        email: faker.internet.email(),
        secret: faker.internet.password(),
      );

      await sut.auth((paramns));

      verify(
        () => httpClient.request(
          url: url,
          method: 'post',
          body: {
            'email': paramns.email,
            'password': paramns.secret,
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

      final paramns = AuthenticationParams(
        email: faker.internet.email(),
        secret: faker.internet.password(),
      );
      final future = sut.auth((paramns));

      expect(future, throwsA(DomainError.unexpected));
    },
  );
}
