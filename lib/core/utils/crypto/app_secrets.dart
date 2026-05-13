import 'dart:convert';
import 'package:flutter/services.dart';

class AppSecrets {
  static bool _loaded = false;
  static late final Uint8List secretKeyBytes;

  static Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('.env');
    final value = _readValue(raw, 'secretKey') ?? _readValue(raw, 'SECRET_KEY');
    if (value == null || value.trim().isEmpty) {
      throw Exception('Missing secretKey in .env');
    }
    final cleaned = value.trim().replaceAll('"', '').replaceAll("'", '');
    secretKeyBytes = _toKeyBytes(cleaned);
    _loaded = true;
  }

  static String? _readValue(String raw, String key) {
    for (final line in raw.split('\n')) {
      final l = line.trim();
      if (l.isEmpty) continue;
      if (l.startsWith('#')) continue;
      final idx = l.indexOf('=');
      if (idx <= 0) continue;
      final k = l.substring(0, idx).trim();
      if (k != key) continue;
      return l.substring(idx + 1).trim();
    }
    return null;
  }

  static Uint8List _toKeyBytes(String value) {
    // Match backend: CryptoJS.enc.Utf8.parse(key1.padEnd(32, '0'))
    // Always treat the key as a UTF-8 string and pad/truncate to 32 bytes.
    final padded = value.padRight(32, '0').substring(0, 32);
    return Uint8List.fromList(utf8.encode(padded));
  }
}

