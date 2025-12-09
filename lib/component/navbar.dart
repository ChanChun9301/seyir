import 'dart:developer';

import 'package:get/get.dart';
import 'package:seyir/pages/controls/token_control.dart';
import 'package:seyir/utils/logout.dart';
import '/login/LoginScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ionicons/ionicons.dart';
import '/main.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final _appToken = Hive.box('apptoken');
  Future<bool> fetchedToken = Future.value(SeyirApp.tokenNotifier.value);

  void check() async {
    final controller = Get.put<TokenControl>(TokenControl());
    fetchedToken = controller.fetchTokenItems();
    log('!!! TOKEN-naýbar:' + SeyirApp.tokenNotifier.value.toString());
    fetchedToken.then((val) {
      SeyirApp.tokenNotifier.value = val;
    });
  }

  String token = '';

  @override
  void initState() {
    super.initState();
    check();
    setState(() {
      token = _appToken.get("token") ?? '';
    });
  }

  void deleteToken() {
    setState(() {
      _appToken.clear();
      SeyirApp.tokenNotifier.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      color: Theme.of(context).colorScheme.background,
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.background,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 1750,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    child:
                        SeyirApp.themeNotifier.value == ThemeMode.light
                            ? Image.asset(
                              'assets/seyir/nav_logo_light.png',
                              fit: BoxFit.fill,
                            )
                            : Image.asset(
                              'assets/seyir/nav_logo_dark.png',
                              fit: BoxFit.fill,
                            ),
                  ),
                  InkWell(
                    onTap: () {
                      (SeyirApp.tokenNotifier.value != false)
                          ? null
                          : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                    },
                    child: Center(
                      child: Text(
                        (SeyirApp.tokenNotifier.value == true)
                            ? _appToken.get('phone')
                            : 'Belgiňizi giriziň!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 2,
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14,
                          fontFamily: "Bricolage",
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            BoxShadow(
                              color: Color.fromARGB(34, 12, 21, 27),
                              offset: Offset(0, 4),
                              blurRadius: 6.0,
                              spreadRadius: 4.0,
                            ),
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 2, color: Color.fromRGBO(158, 158, 158, 1)),
            ListTile(
              leading: Icon(
                CupertinoIcons.home,
                size: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Baş sahypa',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: "Bricolage",
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: SizedBox(
                height: 25,
                width: 25,
                child:
                    SeyirApp.themeNotifier.value == ThemeMode.light
                        ? Image.asset('assets/delivery_icon.png')
                        : Image.asset('assets/delivery_icon_white.png'),
              ),
              // Icon(
              //   CupertinoIcons.car_detailed,
              //   size: 24,
              //   color: Theme.of(context).colorScheme.secondary,
              // ),
              title: Text(
                'Logistika',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: "Bricolage",
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/logist');
              },
            ),
            ListTile(
              leading: Icon(
                Ionicons.car_outline,
                size: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Awtoulaglar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: "Bricolage",
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/car');
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.news,
                size: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Hyzmatlar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: "Bricolage",
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/service');
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.settings,
                size: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Awto şaýlary',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: "Bricolage",
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/spare');
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.news,
                size: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Bildirişlerim',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: "Bricolage",
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/added_list');
              },
            ),
            ListTile(
              onTap: () {
                SeyirApp.themeNotifier.value =
                    SeyirApp.themeNotifier.value == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
              },
              leading: Icon(
                SeyirApp.themeNotifier.value == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              title: Text(
                SeyirApp.themeNotifier.value == ThemeMode.light
                    ? 'Garaňky'
                    : 'Ýagty',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: "Bricolage",
                  fontSize: 14,
                ),
              ),
            ),
            const Divider(height: 2, color: Colors.grey),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              title: Text(
                'Ulgamdan çyk',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: "Bricolage",
                  fontSize: 14,
                ),
              ),
              onTap: () {
                logout(token, false);
                deleteToken();
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
