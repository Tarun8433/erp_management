import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:erp_management/routes/app_routes.dart';
import '../../utils/local_storage/storage_helper.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class MultipartFilePath {
  final String field;
  final String path;
  final String? filename;
  final MediaType? contentType;

  const MultipartFilePath({
    required this.field,
    required this.path,
    this.filename,
    this.contentType,
  });
}

class ApiService {
  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Exception _mapNetworkException(Object e, Uri uri) {
    if (e is SocketException) {
      final isDns =
          (e.osError?.errorCode == 8) ||
          e.message.toLowerCase().contains('failed host lookup');
      if (isDns) {
        return Exception("No Internet"
          //'Network error: cannot resolve ${uri.host}. Check internet/VPN/DNS.',
        );
      }
      return Exception('Network error: ${e.message}');
    }
    if (e is http.ClientException) {
      return Exception('Network error: ${e.message}');
    }
    return Exception(e.toString());
  }

  Future<void> _checkTokenExpiration(dynamic response) async {
    if (response is Map<String, dynamic>) {
      final message = response['message']?.toString();
      final error = response['error']?.toString();

      if ((message != null &&
              (message.contains('TOKEN_EXPIRED') ||
                  message.contains('Wrong Token'))) ||
          (error != null &&
              (error.contains('TOKEN_EXPIRED') ||
                  error.contains('Wrong Token')))) {
        FocusManager.instance.primaryFocus?.unfocus();
        await StorageHelper.clearUserData();
        Get.offAllNamed(AppRoutes.splash);
        throw Exception('Session Expired');
      }
    }
  }

  Future<Map<String, String>> _getCommonHeaders() async {
    final token = await StorageHelper.getToken();
    final language = await StorageHelper.getLanguage() ?? 'en';
    final companyId = await StorageHelper.getSelectedCompanyId();
    final branchId = await StorageHelper.getSelectedBranchId();
    final roleId = await StorageHelper.getSelectedRoleId();
    final financialYear = await StorageHelper.getSelectedFinancialYear();

    String timeZone = 'Asia/Kolkata';
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      timeZone = tzInfo.identifier;
    } catch (e) {
      log('Failed to get timezone: $e');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Connection': 'keep-alive',
      'Language': language,
      // 'Origin': 'http://localhost:4200',
      // 'Referer': 'http://localhost:4200/',
      'Timezone': timeZone,
      'x-platform': 'MOBILE',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',
    };

    if (token != null) {
      headers['Authorization'] =
          token.toLowerCase().startsWith('bearer ') ? token : 'bearer $token';
    }
    if (companyId != null) {
      headers['Company'] = companyId;
      headers['company'] = companyId;
    }
    if (branchId != null) {
      headers['Branch'] = branchId;
      headers['branch'] = branchId;
    }
    if (roleId != null) {
      headers['Role'] = roleId;
      headers['role'] = roleId;
    }
    if (financialYear != null && financialYear.code != null) {
      headers['Year'] = financialYear.code!;
      headers['year'] = financialYear.code!;
    }
    log('TOKEN: $token');
    return headers;
  }

  Future<dynamic> getJson(Uri uri, {Map<String, String>? headers}) async {
    final commonHeaders = await _getCommonHeaders();
    if (headers != null) {
      commonHeaders.addAll(headers);
    }

    http.Response res;
    try {
      res = await _client
          .get(uri, headers: commonHeaders)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw _mapNetworkException(e, uri);
    }
    if ((res.statusCode >= 200 && res.statusCode < 300) ||
        (res.statusCode >= 400 && res.statusCode < 500) ||
        res.statusCode == 500) {
      debugPrint("getJson: $uri - ${res.statusCode} - ${res.body}");
      try {
        final decoded = jsonDecode(res.body);
        await _checkTokenExpiration(decoded);
        return decoded;
      } catch (e) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          rethrow;
        }
      }
    }
    throw Exception('HTTP ${res.statusCode}');
  }

  Future<dynamic> postJson(
    Uri uri,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    log("postJson: $uri, ${jsonEncode(body)}");

    final finalHeaders = await _getCommonHeaders();

    if (headers != null) {
      finalHeaders.addAll(headers);
    }

    http.Response res;
    try {
      res = await _client
          .post(uri, headers: finalHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw _mapNetworkException(e, uri);
    }
    log("postJson: uri: $uri:=> ${res.statusCode} - ${res.body}");

    if ((res.statusCode >= 200 && res.statusCode < 300) ||
        (res.statusCode >= 400 && res.statusCode < 500) ||
        res.statusCode == 500) {
      try {
        final decoded = jsonDecode(res.body);
        await _checkTokenExpiration(decoded);
        return decoded;
      } catch (e) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          rethrow;
        }
        // For error codes, if json decode fails, throw the HTTP exception
      }
    }

    throw Exception('HTTP ${res.statusCode}');
  }

  Future<Map<String, dynamic>> postJsonWithMeta(
    Uri uri,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    log("postJsonWithMeta: $uri, ${jsonEncode(body)}");

    final finalHeaders = await _getCommonHeaders();
    if (headers != null) {
      finalHeaders.addAll(headers);
    }

    http.Response res;
    try {
      res = await _client
          .post(uri, headers: finalHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw _mapNetworkException(e, uri);
    }

    log("postJsonWithMeta: uri: $uri:=> ${res.statusCode} - ${res.body}");

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
      await _checkTokenExpiration(decoded);
    } catch (_) {
      decoded = null;
    }

    final meta = <String, dynamic>{
      'statusCode': res.statusCode,
      'retryAfterSeconds': int.tryParse(res.headers['retry-after'] ?? ''),
      'rateLimitResetSeconds': int.tryParse(
        res.headers['ratelimit-reset'] ?? '',
      ),
    };

    if (decoded is Map<String, dynamic>) {
      return <String, dynamic>{...decoded, '_meta': meta};
    }
    return <String, dynamic>{'data': decoded ?? res.body, '_meta': meta};
  }

  Future<dynamic> postJsonWithoutBody(Uri uri) async {
    final finalHeaders = await _getCommonHeaders();

    final res = await _client
        .post(uri, headers: finalHeaders, body: jsonEncode({}))
        .timeout(const Duration(seconds: 15));
    debugPrint("postJsonWithoutBody: uri: $uri:=>: ${res.statusCode} - ${res.body}");
    if ((res.statusCode >= 200 && res.statusCode < 300) ||
        (res.statusCode >= 400 && res.statusCode < 500) ||
        res.statusCode == 500) {
      try {
        final decoded = jsonDecode(res.body);
        await _checkTokenExpiration(decoded);
        return decoded;
      } catch (e) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          rethrow;
        }
      }
    }
    throw Exception('HTTP ${res.statusCode}');
  }

  Future<dynamic> postMultipart(
    Uri uri, {
    required Map<String, String> fields,
    required Map<String, String> headers,
    List<http.MultipartFile>? files,
  }) async {
    log(
      "postMultipart: $uri, fields: $fields, files: ${files?.map((f) => '${f.field}(${(f.length / 1024).toStringAsFixed(1)}KB)').toList()}",
    );
    var request = http.MultipartRequest('POST', uri);

    final commonHeaders = await _getCommonHeaders();
    commonHeaders.removeWhere((k, v) => k.toLowerCase() == 'content-type');
    request.headers.addAll(commonHeaders);
    request.headers.addAll(headers);
    request.fields.addAll(fields);

    if (files != null) {
      request.files.addAll(files);
    }

    log(
      "postMultipart SENDING: files count=${request.files.length}, fields=${request.fields.keys.toList()}, fileFields=${request.files.map((f) => '${f.field}:${f.filename}(${(f.length / 1024).toStringAsFixed(1)}KB)').toList()}",
    );
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );
    final response = await http.Response.fromStream(streamedResponse);

    log("postMultipart RESPONSE: ${response.statusCode} - ${response.body}");
    if ((response.statusCode >= 200 && response.statusCode < 300) ||
        (response.statusCode >= 400 && response.statusCode < 500) ||
        response.statusCode == 429 ||
        response.statusCode == 500) {
      try {
        final decoded = jsonDecode(response.body);
        await _checkTokenExpiration(decoded);
        return decoded;
      } catch (e) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          rethrow;
        }
      }
    }
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }

  Future<dynamic> postMultipartFromPaths(
    Uri uri, {
    required Map<String, String> fields,
    Map<String, String>? headers,
    List<MultipartFilePath>? files,
  }) async {
    final builtFiles = <http.MultipartFile>[];
    if (files != null && files.isNotEmpty) {
      for (final file in files) {
        builtFiles.add(
          await http.MultipartFile.fromPath(
            file.field,
            file.path,
            filename: file.filename,
            contentType: file.contentType,
          ).timeout(const Duration(minutes: 1)),
        );
      }
    }

    return postMultipart(
      uri,
      fields: fields,
      headers: headers ?? {},
      files: builtFiles.isEmpty ? null : builtFiles,
    );
  }

  Future<dynamic> putMultipart(
    Uri uri, {
    required Map<String, String> fields,
    required Map<String, String> headers,
    List<http.MultipartFile>? files,
  }) async {
    log("putMultipart: $uri, fields: $fields");
    var request = http.MultipartRequest('PUT', uri);

    final commonHeaders = await _getCommonHeaders();
    commonHeaders.removeWhere((k, v) => k.toLowerCase() == 'content-type');
    request.headers.addAll(commonHeaders);
    request.headers.addAll(headers);
    request.fields.addAll(fields);

    if (files != null) {
      request.files.addAll(files);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    log("putMultipart: ${response.statusCode} - ${response.body}");
    if ((response.statusCode >= 200 && response.statusCode < 300) ||
        (response.statusCode >= 400 && response.statusCode < 500) ||
        response.statusCode == 429 ||
        response.statusCode == 500) {
      try {
        final decoded = jsonDecode(response.body);
        await _checkTokenExpiration(decoded);
        return decoded;
      } catch (e) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          rethrow;
        }
      }
    }
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }

  Future<dynamic> putMultipartFromPaths(
    Uri uri, {
    required Map<String, String> fields,
    Map<String, String>? headers,
    List<MultipartFilePath>? files,
  }) async {
    final builtFiles = <http.MultipartFile>[];
    if (files != null && files.isNotEmpty) {
      for (final file in files) {
        builtFiles.add(
          await http.MultipartFile.fromPath(
            file.field,
            file.path,
            filename: file.filename,
            contentType: file.contentType,
          ),
        );
      }
    }

    return putMultipart(
      uri,
      fields: fields,
      headers: headers ?? {},
      files: builtFiles.isEmpty ? null : builtFiles,
    );
  }

  Future<dynamic> deleteJson(Uri uri, Map<String, dynamic> body) async {
    log("deleteJson: $uri, ${jsonEncode(body)}");

    final finalHeaders = await _getCommonHeaders();

    final res = await _client
        .delete(uri, headers: finalHeaders, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    log("deleteJson: uri: $uri:=> ${res.statusCode} - ${res.body}");

    if ((res.statusCode >= 200 && res.statusCode < 300) ||
        (res.statusCode >= 400 && res.statusCode < 500) ||
        res.statusCode == 500) {
      try {
        final decoded = jsonDecode(res.body);
        await _checkTokenExpiration(decoded);
        return decoded;
      } catch (e) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          rethrow;
        }
      }
    }
    throw Exception('HTTP ${res.statusCode}');
  }

  Future<dynamic> putJson(Uri uri, Map<String, dynamic> body) async {
    log("putJson: $uri, ${jsonEncode(body)}");

    final finalHeaders = await _getCommonHeaders();

    final res = await _client
        .put(uri, headers: finalHeaders, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    log("putJson: uri: $uri:=> ${res.statusCode} - ${res.body}");

    if ((res.statusCode >= 200 && res.statusCode < 300) ||
        (res.statusCode >= 400 && res.statusCode < 500) ||
        res.statusCode == 500) {
      try {
        final decoded = jsonDecode(res.body);
        await _checkTokenExpiration(decoded);
        return decoded;
      } catch (e) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          rethrow;
        }
      }
    }
    throw Exception('HTTP ${res.statusCode}');
  }

  Future<dynamic> postJsonList(
    Uri uri,
    List<dynamic> body, {
    Map<String, String>? headers,
  }) async {
    log("postJsonList: $uri, ${jsonEncode(body)}");

    final finalHeaders = await _getCommonHeaders();
    if (headers != null) {
      finalHeaders.addAll(headers);
    }

    http.Response res;
    try {
      res = await _client
          .post(uri, headers: finalHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw _mapNetworkException(e, uri);
    }
    log("postJsonList: uri: $uri:=> ${res.statusCode} - ${res.body}");

    if ((res.statusCode >= 200 && res.statusCode < 300) ||
        (res.statusCode >= 400 && res.statusCode < 500) ||
        res.statusCode == 500) {
      try {
        final decoded = jsonDecode(res.body);
        await _checkTokenExpiration(decoded);
        return decoded;
      } catch (e) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          rethrow;
        }
      }
    }

    throw Exception('HTTP ${res.statusCode}');
  }

  Future<dynamic> postMultipartnew(
    Uri endpoint,
    Map<String, dynamic> fields,
  ) async {
    final request = http.MultipartRequest('POST', endpoint);

    final commonHeaders = await _getCommonHeaders();
    commonHeaders.removeWhere((k, v) => k.toLowerCase() == 'content-type');
    request.headers.addAll(commonHeaders);

    for (final entry in fields.entries) {
      if (entry.value is File) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value.path),
        );
      } else {
        request.fields[entry.key] = entry.value.toString();
      }
    }

    log('postMultipartnew: $endpoint fields=${request.fields.keys.toList()} files=${request.files.map((f) => f.field).toList()}');
    final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);
    log('postMultipartnew response: ${response.statusCode} - ${response.body}');

    if ((response.statusCode >= 200 && response.statusCode < 300) ||
        (response.statusCode >= 400 && response.statusCode < 500) ||
        response.statusCode == 500) {
      try {
        final decoded = jsonDecode(response.body);
        await _checkTokenExpiration(decoded);
        return decoded;
      } catch (e) {
        if (response.statusCode >= 200 && response.statusCode < 300) rethrow;
      }
    }
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }
}

