import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String baseUrl='http://localhost:8000';
// String baseUrl = 'http://10.10.73.81:8000';
// String baseUrl = 'https://userjames.pythonanywhere.com/';
// String baseUrl = 'http://192.168.0.104:8000';

bool iOS(BuildContext context) {
  bool iOS = Theme.of(context).platform == TargetPlatform.iOS;
  return iOS;
}

height(BuildContext context) {
  double h = MediaQuery.of(context).size.height;
  return h;
}

width(BuildContext context) {
  double w = MediaQuery.of(context).size.width;
  return w;
}

var now = DateTime.now();
var formatter = DateFormat('yyyy-MM-dd');
String formattedDate = formatter.format(now);
