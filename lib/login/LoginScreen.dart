import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:seyir/pages/welcome/welcome_screen.dart';
import '/utils/constants.dart'; // baseUrl
import '/utils/dialogs.dart';
import '/pages/controls/token_control.dart';
import '/pages/homeScreens/home_screen.dart';
import '/widgets/getPhoneModel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController author = TextEditingController();
  final _appTokenBox = Hive.box('apptoken');
  bool _isLoading = false;

  void _showError(String message) {
    showErrorDialog(context, message);
  }

  /// Форматирует телефон → оставляем только 8 цифр
  String _formatPhone(String value) {
    String phone = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.startsWith('993')) {
      phone = phone.substring(3);
    }

    if (phone.length != 8) {
      throw Exception("8 belgili telefon giriziň! Mysal: 61234567");
    }

    return phone;
  }

  Future<void> _submitLogin() async {
    late String phone;

    try {
      phone = _formatPhone(author.text);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phoneModel = await getPhoneModel();

      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'author': phone, 'phone_model': phoneModel}),
      );

      if (response.statusCode == 200) {
        _appTokenBox.put('phone', phone);
        _appTokenBox.put('token', "False");

        await Get.put(TokenControl()).fetchTokenItems();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      } else {
        final error = jsonDecode(response.body)['error'];
        _showError(error ?? 'Ýalňyşlyk ýüze çykdy');
      }
    } catch (e) {
      _showError("Serwer bilen baglanyşykda ýalňyşlyk: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    author.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Telefon belgiňizi giriziň!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff296e48),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mysal: 61234567',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: author,
                  keyboardType: TextInputType.phone,
                  maxLength: 8,
                  decoration: InputDecoration(
                    hintText: '61234567',
                    counterText: '',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    filled: true,
                    fillColor: const Color(0xfff0f0f0),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff296e48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : const Text(
                              'Giriş et',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
