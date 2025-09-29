import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const String _keyStorageKey = 'encryption_key_v1';
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  enc.Key? _cachedKey;

  Future<enc.Key> _getOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;
    String? base64Key = await _secureStorage.read(key: _keyStorageKey);
    if (base64Key == null) {
      final key = enc.Key.fromSecureRandom(32);
      base64Key = base64Encode(key.bytes);
      await _secureStorage.write(key: _keyStorageKey, value: base64Key);
    }
    _cachedKey = enc.Key(base64Decode(base64Key));
    return _cachedKey!;
  }

  Future<String> encryptText(String plainText) async {
    final key = await _getOrCreateKey();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final payload = jsonEncode({
      'iv': base64Encode(iv.bytes),
      'data': encrypted.base64,
    });
    return payload;
  }

  Future<String> decryptText(String cipherPayload) async {
    try {
      final key = await _getOrCreateKey();
      final map = jsonDecode(cipherPayload) as Map<String, dynamic>;
      final iv = enc.IV(base64Decode(map['iv'] as String));
      final data = map['data'] as String;
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decrypt(enc.Encrypted.fromBase64(data), iv: iv);
      return decrypted;
    } catch (_) {
      // If payload is plain text or malformed, return as-is to avoid data loss
      return cipherPayload;
    }
  }
}


