import 'package:flutter/material.dart';
import '/pages/logist/logistmain_list.dart';
import '../pages/homeScreens/home_screen.dart';
import '../widgets/add_lists/added_list.dart';
import '../pages/welcome/welcome_screen.dart';
import '../pages/lists/main_list.dart';
// import '../pages/news/news_mainlist.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => const HomeScreen(),
  // '/news': (context) => const NewsMainList(),
  '/welcome': (context) => const WelcomeScreen(),
  '/added_list': (context) => const AddedList(),
  '/car':
      (context) =>
          MainList(pageName: 'Awtoulaglar', filter: '', queryName: 'car'),
  // '/other': (context) => const MainList(
  //       pageName: 'Beýlekiler',
  //       queryName: 'other',
  //     ),
  '/spare':
      (context) =>
          MainList(pageName: 'Awto şaýlary', filter: '', queryName: 'spares'),
  '/logist': (context) => LogistMainList(filter: ''),
  '/service':
      (context) =>
          MainList(pageName: 'Hyzmatlar', filter: '', queryName: 'hyzmatlar'),
};
