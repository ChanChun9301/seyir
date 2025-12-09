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

  Future<void> clearToken() async {
    token = null;
    await Hive.box('apptoken').delete('token');
    log('Token cleared');
  }

  Future<bool> fetchTokenItems() async {
    final box = Hive.box('apptoken');
    final storedToken = box.get('token') as String?;
    final phone = box.get('phone') as String?;

    if (storedToken == null || phone == null) return false;

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/user-check/?author=${phone.substring(3)}&token=$storedToken',
        ),
      );
      log('response.statusCode:' + response.statusCode.toString());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] == true) {
          token = storedToken;
          log('Token is valid.');
          return true;
        }
      }
    } catch (e) {
      log('Error verifying token: $e');
    }

    token = null;
    return false;
  }
}
