import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Hash de contraseña para almacenamiento local (SHA-256).
class PasswordHash {
  PasswordHash._();

  static String hash(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static bool verify(String password, String storedHash) {
    return hash(password) == storedHash;
  }
}
