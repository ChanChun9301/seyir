import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer';
import './pages/controls/token_control.dart';
import 'utils/routes.dart';
import 'utils/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('apptoken');

  final tokenController = Get.put(TokenControl());

  // 1️⃣ Сохраняем phone (обычно после логина)
  await Hive.box('apptoken').put('phone', '61232323');

  // 2️⃣ Сохраняем token, если он есть
  await tokenController.saveToken("False");

  // 3️⃣ Проверяем токен
  bool hasToken = await tokenController.fetchTokenItems();
  log("Has token: $hasToken");

  runApp(const SeyirApp());
}

class SeyirApp extends StatefulWidget {
  const SeyirApp({Key? key}) : super(key: key);

  static final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
  static final tokenNotifier = ValueNotifier<bool>(false);

  @override
  State<SeyirApp> createState() => _SeyirAppState();
}

class _SeyirAppState extends State<SeyirApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SeyirApp.themeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: SeyirApp.tokenNotifier,
          builder: (context, hasToken, __) {
            return GetMaterialApp(
              title: 'Seýir',
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: lightTheme,
              darkTheme: darkTheme,
              initialRoute: hasToken ? '/home' : '/welcome',
              routes: appRoutes,
            );
          },
        );
      },
    );
  }
}
