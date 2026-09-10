import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
    void Function(String)? logger,
  }) : _client = client ?? http.Client(),
       _logger = logger ?? debugPrint;

  final http.Client _client;
  final Duration timeout;
  final void Function(String) _logger;
  static final _baseUrl = Uri.parse('https://fakestoreapi.com/');

  Future<Object?> get(String path) async {
    final uri = _baseUrl.resolve(path);
    final watch = Stopwatch()..start();
    _log('REQUEST GET $uri\nHeaders: {Accept: application/json}\nBody: <none>');
    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(timeout);
      final headers = Map.of(response.headers)
        ..remove('set-cookie')
        ..remove('authorization');
      _log(
        'RESPONSE GET $uri\nStatus: ${response.statusCode} '
        '(${watch.elapsedMilliseconds} ms)\nHeaders: $headers\nBody: ${response.body}',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          response.statusCode == 429
              ? 'Too many requests. Please wait a moment and try again.'
              : 'The store is unavailable right now. Please try again.',
        );
      }
      return jsonDecode(response.body);
    } on TimeoutException {
      _log('ERROR GET $uri: timed out after ${watch.elapsedMilliseconds} ms');
      throw const ApiException(
        'The store took too long to respond. Please try again.',
      );
    } on http.ClientException catch (error) {
      _log('ERROR GET $uri: $error');
      throw const ApiException(
        'Could not connect to the store. Check your internet and try again.',
      );
    } on FormatException catch (error) {
      _log('ERROR GET $uri: invalid JSON: $error');
      throw const ApiException(
        'The store sent an unexpected response. Please try again.',
      );
    }
  }

  void _log(String message) {
    if (kDebugMode) _logger('[FakeStore] $message');
  }

  void close() => _client.close();
}
