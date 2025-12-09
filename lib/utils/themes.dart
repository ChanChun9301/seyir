import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  secondaryHeaderColor: const Color(0xff296e48),
  appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
  colorScheme: const ColorScheme.dark(
    background: Color(0xfff5f6fb),
    primary: Color(0xff296e48),
    secondary: Colors.black,
    onSecondary: Color.fromARGB(255, 90, 90, 90),
    secondaryContainer: Colors.white,
    primaryContainer: Colors.white,
    onBackground: Color.fromARGB(255, 236, 198, 198),
  ),
);

ThemeData darkTheme = ThemeData(
  // brightness: Brightness.dark,
  secondaryHeaderColor: Colors.grey[200]!,
  colorScheme: const ColorScheme.dark(
    background: Color(0xff2C2C2C),
    primary: Color(0xff424242),
    secondary: Color.fromARGB(255, 228, 226, 226),
    onSecondary: Color.fromARGB(255, 210, 209, 209),
    primaryContainer: Color(0xff424242),
    secondaryContainer: Color(0xff1c212e),
    onBackground: Color.fromARGB(255, 240, 180, 179),
  ),
);
