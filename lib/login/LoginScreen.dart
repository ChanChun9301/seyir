import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/adapters.dart';
import 'package:seyir/main.dart';
import 'package:seyir/pages/controls/token_control.dart';
import '/utils/constants.dart';
import '/utils/dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController author = TextEditingController();
  final _appTokenBox = Hive.box('apptoken');
  bool _isLoading = false;
  bool _isError = false;

  @override
  void dispose() {
    author.dispose();
    super.dispose();
  }

  Future<void> checkToken() async {
    final controller = Get.put<TokenControl>(TokenControl());
    bool val = await controller.fetchTokenItems();
    SeyirApp.tokenNotifier.value = val;
    debugPrint('Token valid: $val');
  }

  void addToken(String token) {
    _appTokenBox.put('token', token);
    debugPrint('Token saved: $token');
  }

  void _showError(String message) {
    showErrorDialog(context, message);
  }

  bool _validateInput() {
    if (author.text.isEmpty || author.text.length < 8) {
      _showError("Telefon belgiňizi doly we dogry giriziň.");
      return false;
    }
    return true;
  }

  Future<void> _submitLogin() async {
    if (!_validateInput()) return;

    setState(() => _isLoading = true);

    final body = {
      'author': author.text.substring(3),
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/userprod-list/'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        log('Login success: $data');
        addToken(author.text.substring(3));
        await checkToken();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SeyirApp()),
        );
      } else {
        _showError('Login başarısız: Serwerden nädogry jogap alyndy.');
        log('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showError('Ýalňyşlyk ýüze çykdy. Ýene synanyşyň.');
      log('Login error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Telefon belgiňizi giriziň!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff296e48),
                      fontFamily: 'Bricolage',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Telefon belgiňizi girizmeklik bilen siz bildirişleriňizi girizip hem-de dolandyryp bilersiňiz.\nOnuň üçin 99361661764 belgä boş sms ugradyň we jogabyna garasyň.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff707B81),
                      fontFamily: 'Bricolage',
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: author,
                    maxLength: 11,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '9936*******',
                      filled: true,
                      fillColor: const Color(0xfff7f7f9),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff6a6a6a),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff296e48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Tassykla',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Bricolage',
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
