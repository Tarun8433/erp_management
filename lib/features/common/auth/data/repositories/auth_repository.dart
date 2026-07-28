import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/api/api_service.dart';
import '../../../../../core/services/api/endpoints.dart';
import '../../../../../core/utils/crypto/aes_crypto.dart';
import '../../../../../core/utils/crypto/app_secrets.dart';
import '../models/login_response.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({ApiService? apiService})
    : _apiService = apiService ?? Get.find<ApiService>();

  /// Login using the new SchoolClub.in API.
  /// Sends plain text userName + password (no encryption needed).
  Future<LoginResponse> login(
    String userName,
    String password, {
    bool rememberMe = true,
    int tenantId = 0,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'userName': userName,
        'password': password,
        'rememberMe': rememberMe,
        'tenantId': tenantId,
      };

      final response = await _apiService.postJson(Endpoints.login(), body);
      log("Login Response: ${jsonEncode(response)}");
      return LoginResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // TODO: Methods below still use old API patterns.
  // They are kept for compile compatibility with other features
  // (OTP, MPIN, forgot password, etc.) and should be updated
  // when the new SchoolClub.in API adds support for them.

  Future<dynamic> sendOtp(
    String mobile, String purpose, {
    bool isLogin = false,
    String? countryCode,
  }) async {
    try {
      final body = <String, dynamic>{'mobile': mobile, 'purpose': purpose};
      if (countryCode != null && countryCode.isNotEmpty) {
        body['countryCode'] = countryCode;
      }

      final response = await _apiService.postJsonWithMeta(
        isLogin ? Endpoints.loginOtpGenerate() : Endpoints.otpGenerate(),
        body,
      );
      debugPrint("OTP Response: ${jsonEncode(response)}");
     
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> verifyOtp(String mobile, String otp, String purpose) async {
    try {
      final response = await _apiService.postJson(Endpoints.verifyOtp(), {
        'mobile': mobile,
        'otp': otp,
        "purpose": purpose,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> forgotPassword({
    required String mobile,
    required String resetToken,
    required String password,
  }) async {
    try {
      final encrypted = AesCrypto.encryptCbcPkcs7(
        plaintext: password,
        keyBytes: AppSecrets.secretKeyBytes,
      );
      final response = await _apiService.postJson(Endpoints.forgotPassword(), {
        'mobile': mobile,
        'password': encrypted.cipherTextBase64,
        'iv': encrypted.ivBase64,
        'resetToken': resetToken,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> forgotMpin({
    required String mobile,
    required String resetToken,
    required String mpin,
  }) async {
    try {
      final encrypted = AesCrypto.encryptCbcPkcs7(
        plaintext: mpin,
        keyBytes: AppSecrets.secretKeyBytes,
      );
      final response = await _apiService.postJson(Endpoints.forgotMpin(), {
        'mobile': mobile,
        'mpin': encrypted.cipherTextBase64,
        'iv': encrypted.ivBase64,
        'resetToken': resetToken,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final oldEnc = AesCrypto.encryptCbcPkcs7(
        plaintext: oldPassword,
        keyBytes: AppSecrets.secretKeyBytes,
      );
      final newEnc = AesCrypto.encryptCbcPkcs7(
        plaintext: newPassword,
        keyBytes: AppSecrets.secretKeyBytes,
      );
      final response = await _apiService.postJson(Endpoints.changePassword(), {
        'oldPassword': oldEnc.cipherTextBase64,
        'oldPasswordIv': oldEnc.ivBase64,
        'newPassword': newEnc.cipherTextBase64,
        'newPasswordIv': newEnc.ivBase64,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> changeMpin({
    required String oldMpin,
    required String newMpin,
  }) async {
    try {
      final oldEnc = AesCrypto.encryptCbcPkcs7(
        plaintext: oldMpin,
        keyBytes: AppSecrets.secretKeyBytes,
      );
      final newEnc = AesCrypto.encryptCbcPkcs7(
        plaintext: newMpin,
        keyBytes: AppSecrets.secretKeyBytes,
      );
      final response = await _apiService.postJson(Endpoints.changeMpin(), {
        'oldMpin': oldEnc.cipherTextBase64,
        'oldMpinIv': oldEnc.ivBase64,
        'newMpin': newEnc.cipherTextBase64,
        'newMpinIv': newEnc.ivBase64,
        'iv': newEnc.ivBase64,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> setMpin({
    required String mobile,
    required String mpin,
    String? companyIdOverride,
  }) async {
    try {
      final headers = <String, String>{};
      if (companyIdOverride != null && companyIdOverride.isNotEmpty) {
        headers['company'] = companyIdOverride;
      }
      final encrypted = AesCrypto.encryptCbcPkcs7(
        plaintext: mpin,
        keyBytes: AppSecrets.secretKeyBytes,
      );
      final response = await _apiService.postJsonWithMeta(
        Endpoints.userSetMpin(),
        {
          'mobile': mobile,
          'mpin': encrypted.cipherTextBase64,
          'iv': encrypted.ivBase64,
        },
        headers: headers.isEmpty ? null : headers,
      );
      debugPrint("Set MPIN Response: ${jsonEncode(response)}");
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
