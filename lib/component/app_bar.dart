// ignore_for_file: file_names
import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  final String name;
  final String route;
  final IconData icons;
  const AppBarWidget(
      {Key? key, required this.name, required this.route, required this.icons})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      centerTitle: true,
      title: Text(
        name,
        style: const TextStyle(
            letterSpacing: 0,
            fontFamily: "Bricolage",
            fontSize: 16,
            color: Colors.white),
      ),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(
              icons,
              color: Colors.white,
              size: 16,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
    );
  }
}
