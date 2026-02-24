// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ListAppbar extends StatelessWidget {
  final String titleName;
  final String query;
  const ListAppbar({Key? key, required this.titleName, required this.query})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 10,
      centerTitle: true,
      title: Text(
        titleName,
        style: const TextStyle(
          // fontStyle: FontStyle.italic,
          letterSpacing: 2,
          fontFamily: "Bricolage",
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(
              Icons.sort_outlined,
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
    );
  }
}
