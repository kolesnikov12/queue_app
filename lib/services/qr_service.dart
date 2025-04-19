import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

class QrService {
  // Генерація унікального QR-коду для черги або команди
  Future<String> generateQrCode(String id) async {
    try {
      // Створюємо об'єкт даних з ідентифікатором та тимчасовою міткою
      final Map<String, dynamic> data = {
        'id': id,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'random': _generateRandomString(8),
      };

      // Кодуємо дані у формат JSON
      final jsonData = jsonEncode(data);

      // Кодуємо у Base64 для зменшення розміру QR-коду
      final base64Data = base64Encode(utf8.encode(jsonData));

      return base64Data;
    } catch (e) {
      rethrow;
    }
  }

  // Генерація QR-коду для чемпіонату
  Future<String> generateChampionshipQrCode(String championshipId) async {
    try {
      // Додаємо префікс для визначення типу QR-коду
      final Map<String, dynamic> data = {
        'type': 'championship',
        'id': championshipId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'random': _generateRandomString(8),
      };

      // Кодуємо дані у формат JSON
      final jsonData = jsonEncode(data);

      // Кодуємо у Base64 для зменшення розміру QR-коду
      final base64Data = base64Encode(utf8.encode(jsonData));

      return base64Data;
    } catch (e) {
      rethrow;
    }
  }

  // Генерація QR-коду для команди
  Future<String> generateTeamQrCode(String teamId) async {
    try {
      // Додаємо префікс для визначення типу QR-коду
      final Map<String, dynamic> data = {
        'type': 'team',
        'id': teamId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'random': _generateRandomString(8),
      };

      // Кодуємо дані у формат JSON
      final jsonData = jsonEncode(data);

      // Кодуємо у Base64 для зменшення розміру QR-коду
      final base64Data = base64Encode(utf8.encode(jsonData));

      return base64Data;
    } catch (e) {
      rethrow;
    }
  }

  // Декодування QR-коду
  Future<Map<String, dynamic>> decodeQrCode(String qrData) async {
    try {
      // Декодуємо з Base64
      final decodedBytes = base64Decode(qrData);
      final decodedString = utf8.decode(decodedBytes);

      // Парсимо JSON
      final Map<String, dynamic> data = jsonDecode(decodedString);

      return data;
    } catch (e) {
      rethrow;
    }
  }

  // Копіювання QR-коду в буфер обміну
  Future<void> copyQrToClipboard(String qrData) async {
    try {
      await Clipboard.setData(ClipboardData(text: qrData));
    } catch (e) {
      rethrow;
    }
  }

  // Генерація випадкового рядка
  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Генерація унікального імені користувача
  String generateUniqueUsername() {
    final adjectives = [
      'happy', 'funny', 'clever', 'brave', 'cool', 'smart', 'kind', 'bright',
      'epic', 'awesome', 'amazing', 'super', 'mega', 'ultra', 'great',
    ];

    final nouns = [
      'wolf', 'tiger', 'eagle', 'lion', 'falcon', 'dolphin', 'shark', 'bear',
      'dragon', 'knight', 'wizard', 'ninja', 'samurai', 'hero', 'legend',
    ];

    final random = Random.secure();
    final adjective = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];
    final number = random.nextInt(1000);

    return '$adjective$noun$number';
  }

  // Генерація хешу для верифікації QR-коду
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}