import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  ImageUtils._();

  static CompressFormat _formatFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return CompressFormat.png;
    return CompressFormat.jpeg;
  }

  /// Compresses [file] and returns the bytes.
  /// [quality] 0–100 (JPEG/WebP). Default 70 is a good balance for uploads.
  /// Automatically picks JPEG for photos, PNG only when the extension demands it.
  static Future<List<int>> compress(
    File file, {
    int quality = 70,
    int minWidth = 1024,
    int minHeight = 1024,
  }) async {
    final format = _formatFor(file.path);

    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: format,
    );

    if (result == null) {
      log('ImageUtils.compress: compression returned null, using original bytes');
      return await file.readAsBytes();
    }

    final originalKb = (await file.length()) / 1024;
    final compressedKb = result.length / 1024;
    log(
      'ImageUtils.compress: ${originalKb.toStringAsFixed(1)}KB → '
      '${compressedKb.toStringAsFixed(1)}KB '
      '(quality=$quality, format=${format.name})',
    );
    return result;
  }

  /// Compresses [file] and returns a Base64 string ready for JSON payload.
  static Future<String> compressAndToBase64(
    File file, {
    int quality = 70,
    int minWidth = 1024,
    int minHeight = 1024,
  }) async {
    final bytes = await compress(
      file,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
    );
    return base64Encode(bytes);
  }

  /// Converts [file] to Base64 without compression (use for small files / PDFs).
  static Future<String> toBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }
}
