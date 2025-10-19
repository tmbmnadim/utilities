import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'exceptions.dart';

class ApiManager<T> {
  final String _baseUrl;
  final bool _debug;
  ApiManager({required String baseUrl, bool debug = false})
    : _baseUrl = baseUrl,
      _debug = debug;

  /// This is the top request. The other request derives from this one.
  ///
  /// It can return ether a Map\<String, dynamic\> or List\<Map\<String, dynamic\>\>
  /// or something else(depends on server)
  Future<dynamic> _request({
    required Future<http.Response> Function(Uri) request,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    required String path,
    Map<String, dynamic>? query,
    String? fragment,
  }) async {
    if (_debug) log('BASE URL: $_baseUrl');
    Uri? exUri = Uri.tryParse(_baseUrl);

    if (exUri == null) throw Exception("Invalid or empty uri");

    final uri = Uri(
      scheme: exUri.scheme,
      host: exUri.host,
      path: path,
      queryParameters: query,
      fragment: fragment,
    );

    if (_debug) log('REQUEST URL: ${uri.toString()}');
    if (headers != null && _debug) log('HEADERS    : $headers');
    if (body != null && _debug) log('BODY       : $body');
    if (headers != null && _debug) log('QUERY      : $query');

    // Sending a request
    final response = await request(uri);
    if (_debug) log('RESPONSE BODY: ${response.body.substring(0, 100)}');

    // Extracting the response body
    final result = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (result is List<String>) {
        return result.map((e) => jsonDecode(e) as Map<String, dynamic>);
      } else {
        return result;
      }
    } else {
      throw ServerException(
        code: response.statusCode,
        message: _getErrorMessage(result),
        error: result,
      );
    }
  }

  String _getErrorMessage(dynamic response) {
    if (response is Map<String, dynamic>) {
      if (response.containsKey("message")) {
        return response['message'];
      } else if (response.containsKey("details")) {
        return response['details'];
      }
    }
    return response.toString();
  }

  /// POST: baseUrl/path?queryKey=queryValue&queryKey2=queryValue2
  ///
  /// It can return ether a Map\<String, dynamic\> or List\<Map\<String, dynamic\>\>
  /// or something else(depends on server)
  Future<dynamic> create({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    required String path,
    Map<String, dynamic>? query,
    String? fragment,
  }) async {
    final result = await _request(
      request: (uri) => http.post(uri, headers: headers, body: body),
      path: path,
      headers: headers,
      body: body,
      query: query,
      fragment: fragment,
    );

    return result;
  }

  /// GET: baseUrl/path?queryKey=queryValue&queryKey2=queryValue2
  ///
  /// It can return ether a Map\<String, dynamic\> or List\<Map\<String, dynamic\>\>
  /// or something else(depends on server)
  Future<dynamic> get({
    Map<String, String>? headers,
    required String path,
    Map<String, dynamic>? query,
    String? fragment,
  }) async {
    final result = await _request(
      request: (uri) => http.get(uri, headers: headers),
      path: path,
      headers: headers,
      query: query,
      fragment: fragment,
    );

    return result;
  }

  /// PATCH: baseUrl/path?queryKey=queryValue&queryKey2=queryValue2
  ///
  /// It can return ether a Map\<String, dynamic\> or List\<Map\<String, dynamic\>\>
  /// or something else(depends on server)
  Future<dynamic> update({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    required String path,
    Map<String, dynamic>? query,
    String? fragment,
  }) async {
    final result = await _request(
      request: (uri) => http.put(uri, headers: headers, body: body),
      path: path,
      body: body,
      headers: headers,
      query: query,
      fragment: fragment,
    );

    return result;
  }

  /// DELETE: baseUrl/path?queryKey=queryValue&queryKey2=queryValue2
  ///
  /// It can return ether a Map\<String, dynamic\> or List\<Map\<String, dynamic\>\>
  /// or something else(depends on server)
  Future<dynamic> delete({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    required String path,
    Map<String, dynamic>? query,
    String? fragment,
  }) async {
    final result = await _request(
      request: (uri) => http.delete(uri, headers: headers, body: body),
      path: path,
      body: body,
      headers: headers,
      query: query,
      fragment: fragment,
    );

    return result;
  }
}
