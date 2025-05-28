import 'package:flutter/material.dart';
import '/pages/logist/logistmain_list.dart';
import '../pages/homeScreens/home_screen.dart';
import '../widgets/add_lists/added_list.dart';
import '../pages/welcome/welcome_screen.dart';
import '../pages/lists/main_list.dart';
import '../pages/news/news_mainlist.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => const HomeScreen(),
  '/news': (context) => const NewsMainList(),
  '/welcome': (context) => const WelcomeScreen(),
  '/added_list': (context) => const AddedList(),
  '/car': (context) => const MainList(
        pageName: 'Awtoulaglar',
        queryName: 'car',
      ),
  '/other': (context) => const MainList(
        pageName: 'Beýlekiler',
        queryName: 'other',
      ),
  '/elin': (context) => const MainList(
        pageName: 'Elin hyzmatlar',
        queryName: 'elin',
      ),
  '/logist': (context) => LogistMainList(filter: ''),
  '/service': (context) => const MainList(
        pageName: 'Hyzmatlar',
        queryName: 'service',
      ),
};
