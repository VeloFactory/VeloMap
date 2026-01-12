import 'package:http/http.dart' as http;

class Http extends http.BaseClient {
  Http() : super();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['authorization'] = 'none';

    return request.send();
  }
}
