import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class AesEncryptedPayload {
  final String cipherTextBase64;
  final String ivBase64;

  const AesEncryptedPayload({
    required this.cipherTextBase64,
    required this.ivBase64,
  });
}

class AesCrypto {
  static AesEncryptedPayload encryptCbcPkcs7({
    required String plaintext,
    required Uint8List keyBytes,
  }) {
    final iv = _randomBytes(16);
    final params = PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
      ParametersWithIV<KeyParameter>(KeyParameter(keyBytes), iv),
      null,
    );
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    );
    cipher.init(true, params);
    final input = Uint8List.fromList(utf8.encode(plaintext));
    final output = cipher.process(input);
    return AesEncryptedPayload(
      cipherTextBase64: base64Encode(output),
      ivBase64: base64Encode(iv),
    );
  }

  static String decryptCbcPkcs7({
    required String cipherTextBase64,
    required String ivBase64,
    required Uint8List keyBytes,
  }) {
    final iv = base64Decode(ivBase64);
    final cipherText = base64Decode(cipherTextBase64);
    final params = PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
      ParametersWithIV<KeyParameter>(KeyParameter(keyBytes), iv),
      null,
    );
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    );
    cipher.init(false, params);
    final output = cipher.process(Uint8List.fromList(cipherText));
    return utf8.decode(output);
  }

  static Uint8List _randomBytes(int length) {
    final rnd = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => rnd.nextInt(256)));
  }
}

