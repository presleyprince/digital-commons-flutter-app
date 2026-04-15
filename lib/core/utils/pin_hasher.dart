import 'package:crypto/crypto.dart';
import 'dart:convert';

class PinHasher {
  static String generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return base64Encode(utf8.encode(random));
  }

  static String hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return base64Encode(digest.bytes);
  }

  static bool verifyPin(String inputPin, String hashedPin, String salt) {
    final inputHashedPin = hashPin(inputPin, salt);
    return inputHashedPin == hashedPin;
  }
}
