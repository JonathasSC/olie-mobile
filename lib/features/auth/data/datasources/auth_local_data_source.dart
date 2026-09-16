import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);

  Future<String?> getToken();

  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl(this.secureStorage);

  @override
  Future<void> cacheToken(String token) {
    return secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() {
    return secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> clearToken() {
    return secureStorage.delete(key: _tokenKey);
  }
}
