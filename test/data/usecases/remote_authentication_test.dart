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

  Map mockValidData() => {
        'accessToken': faker.guid.guid(),
        'name': faker.person.name(),
      };
  When mockRequest() => when(() => httpClient.request(
        url: any(named: 'url'),
        method: any(named: 'method'),
        data: any(named: 'body'),
      ));
  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow((error));
  }

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      secret: faker.internet.password(),
    );
    mockHttpData(mockValidData());
  });

  test(
    'Should call HttpClient with the correct values',
    () async {
      await sut.auth((params));

      verify(
        () => httpClient.request(
          url: url,
          method: 'post',
          data: {
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
      mockHttpError(HttpError.badRequest);

      final future = sut.auth((params));

      expect(future, throwsA(DomainError.unexpected));
    },
  );
  test(
    'Should throw UnexpectedError if HttpClient return 404',
    () async {
      mockHttpError(HttpError.notFound);

      final future = sut.auth((params));

      expect(future, throwsA(DomainError.unexpected));
    },
  );
  test(
    'Should throw UnexpectedError if HttpClient return 500',
    () async {
      mockHttpError(HttpError.serverError);

      final future = sut.auth((params));

      expect(future, throwsA(DomainError.unexpected));
    },
  );
  test(
    'Should throw InvalidCredentialError if HttpClient return 401',
    () async {
      mockHttpError(HttpError.unAuthorised);

      final future = sut.auth((params));

      expect(future, throwsA(DomainError.invalidCredentials));
    },
  );
  test(
    'Should return an Account if HttpClient return 200',
    () async {
      final validData = mockValidData();
      mockHttpData(validData);

      final account = await sut.auth((params));

      expect(account.token, validData['accessToken']);
    },
  );
  test(
    'Should throw an UnexpectedError if HttpClient return 200 with invalid data',
    () async {
      mockRequest().thenAnswer((_) async => {
            'invalid_key': 'invalid_value',
          });

      final future = sut.auth((params));

      expect(future, throwsA(DomainError.unexpected));
    },
  );
}
