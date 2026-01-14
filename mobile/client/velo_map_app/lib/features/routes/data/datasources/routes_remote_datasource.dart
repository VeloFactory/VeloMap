import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:velo_map_app/core/errors/data_exceptions.dart';
import '../models/route_dto.dart';

abstract class RoutesRemoteDataSource {
  Future<List<RouteDto>> getRoutes();
}

class RoutesRemoteDataSourceImpl implements RoutesRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  RoutesRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<List<RouteDto>> getRoutes() async {
    final uri = Uri.parse(baseUrl);

    try {
      final response = await client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'X-Test-Header': 'test-value',
            },
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode, body: response.body);
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const InvalidResponseException('Expected JSON object');
      }

      final routesRaw = decoded['routes'];
      if (routesRaw is! List) {
        throw const InvalidResponseException('Field "routes" must be a List');
      }

      return routesRaw
          .map((e) => RouteDto.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on SocketException {
      throw const NetworkException();
    } on FormatException catch (e) {
      // jsonDecode мог упасть
      throw InvalidResponseException('Invalid JSON: ${e.message}');
    }
  }
}
