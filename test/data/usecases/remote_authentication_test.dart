import 'package:faker/faker.dart';
import 'package:flutter_tdd_bdd_solid_clean_arch/domain/usecases/usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({required this.httpClient, required this.url});

  Future<void> auth(AuthenticationParams params) async {
    final body = {'email': params.email, 'password': params.secret};

    await httpClient.request(url: url, method: 'post', body: body);
  }
}

abstract class HttpClient {
  Future<void> request({
    required String url,
    required String method,
    Map body,
  });
}

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
}
