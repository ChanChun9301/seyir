import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:seyir/pages/controls/token_control.dart';
import 'package:url_launcher/url_launcher.dart';
import '/utils/dialogs.dart';
import '/utils/constants.dart'; // baseUrl

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController author = TextEditingController();
  final _appTokenBox = Hive.box('apptoken');
  bool _isLoading = false;
  bool _smsRequested = false;

  @override
  void dispose() {
    author.dispose();
    super.dispose();
  }

  void _showError(String message) {
    showErrorDialog(context, message);
  }

  void saveToken(String token) {
    _appTokenBox.put('token', token);
  }

  Future<void> _sendSmsRequest() async {
    final phone = author.text.trim();

    if (phone.length != 11 || !phone.startsWith('9936')) {
      _showError("Telefon belgiňizi dogry giriziň. Mysal: 9936*******");
      return;
    }

    final smsNumber = phone; // SMS ugradyljak belgä doly belgini ulanyň
    final smsMessage = ""; // boş SMS ugradylýar

    final Uri smsUri = Uri.parse("sms:$smsNumber?body=$smsMessage");

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      setState(() {
        _smsRequested = true;
      });
      showErrorDialog(
        context,
        'Telefon programmasy açyldy, boş SMS ugradyň we soňra tassyklamany geçiň.',
      );
    } else {
      _showError('Telefonuňyz SMS ugratmaga rugsat bermeýär.');
    }
  }

  Future<void> _submitLogin() async {
    final phone = author.text.trim();

    if (!_smsRequested) {
      _showError("Ilki SMS ugradyň!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        body: jsonEncode({'author': phone.substring(3)}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access'];

        saveToken(accessToken);
        await Get.put(TokenControl()).fetchTokenItems();

        Navigator.pushReplacementNamed(context, '/home');
      } else if (response.statusCode == 401) {
        _showError("SMS tassyklamasy edilmändir ýa-da wagty geçipdir.");
      } else {
        _showError("Ýalňyşlyk ýüze çykdy: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Serwer bilen baglanyşykda ýalňyşlyk: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Telefon belgiňizi giriziň!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff296e48),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _smsRequested
                      ? 'SMS ugradyldy! 10 minutyň içinde tassyklamaly.'
                      : '99361661764 belgä boş SMS ugradyň. Soňra tassyklama üçin giriş ediň.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: author,
                  maxLength: 11,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '9936*******',
                    filled: true,
                    fillColor: const Color(0xfff0f0f0),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendSmsRequest,
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
                                  'SMS ugrat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
