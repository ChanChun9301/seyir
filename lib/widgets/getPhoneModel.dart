import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<String> getPhoneModel() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model ?? 'unknown';
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.utsname.machine ?? 'unknown';
  }
  return 'unknown';
}
