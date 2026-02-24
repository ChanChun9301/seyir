import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:seyir/main.dart';
import 'package:seyir/pages/controls/token_control.dart';
import 'package:seyir/utils/constants.dart';

Future<void> logout(String token, bool check) async {
  Map updatedData = {'author': token, 'checked': false};
  final response = await http.post(
    Uri.parse('$baseUrl/logout/'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(updatedData),
  );

  if (response.statusCode == 200) {
    log('Item updated successfully!');
  } else {
    log('Failed to update item: ${response.body}');
  }
  Future<bool> fetchedToken = Future.value(SeyirApp.tokenNotifier.value);
  void check() async {
    final controller = Get.put<TokenControl>(TokenControl());
    fetchedToken = controller.fetchTokenItems();
    fetchedToken.then((val) {
      SeyirApp.tokenNotifier.value = val;
      debugPrint(val.toString());
    });
  }
}
