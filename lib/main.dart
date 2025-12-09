import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer';
import './pages/controls/token_control.dart';
import 'utils/routes.dart';
import 'utils/themes.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TokenControlAdapter());
  await Hive.openBox('apptoken');

  // Create GetX controller
  final tokenController = Get.put(TokenControl());

  bool hasToken = false;

  try {
    hasToken = await tokenController.fetchTokenItems();
    log(hasToken.toString());
    log('Token check on startup: $hasToken');
    SeyirApp.tokenNotifier.value = hasToken;
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
              initialRoute: hasToken ? '/home' : '/welcome',
              routes: appRoutes,
            );
          },
        );
      },
    );
  }
}
