import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

// Make sure these paths are correct
import 'package:seyir/utils/routes.dart';
import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/themes.dart';
import 'package:seyir/pages/homeScreens/home_screen.dart';

//  Create a Hive Adapter
class TokenControlAdapter extends TypeAdapter<TokenControl> {
  @override
  final int typeId = 0; // Assign a unique ID for your adapter.  Start from 0 and increment.

  @override
  TokenControl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    // Important:  TokenControl should only store the token string, not the whole controller.
    final token = fields[0] as String?; // Read the token.  Use 0 for the token.
    final controller = TokenControl();
    controller.saveToken(token ?? '');
    return controller; //Reconstruct the TokenControl object.  This is important.
  }

  @override
  void write(BinaryWriter writer, TokenControl obj) {
    // Important:  Only write the token string.
    writer.writeByte(1); // Number of fields to write (just the token)
    writer.writeByte(
      0,
    ); // Field ID for the token (should match the read() method)
    writer.write(obj.token); // Write the token string.
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenControlAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TokenControl extends GetxController {
  String? _token;

  String? get token => _token;

  @override
  void onInit() {
    super.onInit();
  }

  Future<bool> fetchTokenItems() async {
    final token = Hive.box('apptoken').get('token') as String?;
    final phone = Hive.box('apptoken').get('phone') as String?;

    log('Fetching token from Hive: $token');
    bool fetchedToken = false;

    if (token == null || token.isEmpty) {
      log('Token is null or empty.  Returning false.');
      _token = null; // Also set the internal token to null
      return false;
    }
    log(token.substring(3).toString());
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/user-check/?author=${phone.toString().substring(3)}&token=$token',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Token???' + data.toString());
        if (data is Map && data['token'] == true) {
          fetchedToken = true;
          _token = token;
          log('Token is valid.');
        } else {
          log('Token is invalid or missing in response.');
          _token = null;
        }
      } else {
        //  Handle HTTP errors.  Don't just return false.  Log the error.
        log(
          'HTTP error: ${response.statusCode} - ${response.body}',
        ); // Include the response body.
        _token = null;
      }
    } catch (error) {
      //  Catch any exceptions, such as network errors or JSON parsing errors.
      log('Error fetching/verifying token: $error');
      _token = null;
    }
    return fetchedToken;
  }

  Future<void> saveToken(String token) async {
    _token = token; // keep the token updated.
    await Hive.box('apptoken').put('token', token);
    log('Token saved to Hive.');
  }

  // Add a method to clear the token.  Useful for logout.
  Future<void> clearToken() async {
    _token = null;
    await Hive.box('apptoken').delete('token');
    log('Token cleared from Hive.');
  }
}
