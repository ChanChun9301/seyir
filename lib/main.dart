import 'package:get/get.dart';
import 'package:seyir/pages/controls/token_control.dart';
import 'utils/routes.dart';
import 'package:flutter/material.dart';
import 'utils/themes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TokenControlAdapter());
  await Hive.openBox('apptoken');
  // await Hive.openBox<TokenControl>('apptoken');

  final tokenController = Get.put(TokenControl());

  try {
    final hasToken = await tokenController.fetchTokenItems();
    log('+++++' + hasToken.toString());
    SeyirApp.tokenNotifier.value = hasToken;
    log('Initial Token State: $hasToken');
  } catch (e) {
    log('Error fetching token on startup: $e');
    SeyirApp.tokenNotifier.value = false;
  }

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
              initialRoute: '/welcome',
              routes: appRoutes,
            );
          },
        );
      },
    );
  }
}
