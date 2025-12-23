import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '/utils/constants.dart';

class TokenControl extends GetxController {
  String? token;

  Future<void> saveToken(String value) async {
    token = value;
    await Hive.box('apptoken').put('token', value);
    log('Token saved: $token');
  }

  Future<void> savePhone(String value) async {
    token = value;
    await Hive.box('apptoken').put('phone', value);
    log('Token saved: $token');
  }

  Future<void> clearToken() async {
    token = null;
    await Hive.box('apptoken').delete('token');
    log('Token cleared');
  }

  Future<bool> fetchTokenItems() async {
    log("⚡ fetchTokenItems CALLED!");

    final box = Hive.box('apptoken');
    final storedToken = box.get('token') as String?;
    final phone = box.get('phone') as String?;

    log("storedToken = $storedToken");
    log("phone = $phone");

    if (storedToken == null || phone == null) {
      log("❌ storedToken or phone is NULL");
      return false;
    }

    final url =
        '$baseUrl/user-check/?author=$phone';
    log("❌ Exception: $url");

    log("📤 Sending request to: $url");

    try {
      final response = await http.get(Uri.parse(url));

      log("🟢 Response received");
      log("Status: ${response.statusCode}");
      log("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("Decoded JSON: $data");

        if (data['token'] == true) {
          token = storedToken;
          log("✅ Token is valid");
          return true;
        } else {
          log("❌ Token invalid in JSON");
        }
      } else {
        log("❌ Status != 200");
      }
    } catch (e) {
      log("❌ Exception: $e");
    }

    token = null;
    return false;
  }
}
