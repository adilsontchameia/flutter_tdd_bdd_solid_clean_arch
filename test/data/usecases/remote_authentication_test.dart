import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({required this.httpClient, required this.url});

  Future<void> auth() async {
    await httpClient.request(url: url, method: 'post');
  }
}

abstract class HttpClient {
  Future<void> request({
    required String url,
    required String method,
  });
}

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  test(
    'Should call HttpClient with the correct values',
    () async {
      final httpClient = HttpClientSpy();
      final url = faker.internet.httpUrl();

      // Define behavior for the mock
      when(
        () => httpClient.request(
          url: any(named: 'url'),
          method: any(named: 'method'),
        ),
      ).thenAnswer((_) async {}); // sut => system under test
      final sut = RemoteAuthentication(httpClient: httpClient, url: url);
      await sut.auth();

      verify(
        () => httpClient.request(url: url, method: 'post'),
      );
    },
  );
}
