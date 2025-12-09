// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:seyir/pages/logist/logist_search_delagate.dart';
import 'package:seyir/widgets/filterWidget.dart';
import '/pages/lists/address_list.dart';
import '/pages/lists/category_list.dart';
import '/pages/search_delagate.dart';

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
          fontStyle: FontStyle.italic,
          letterSpacing: 2,
          fontFamily: "Bricolage",
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search_outlined),
          tooltip: 'Gözle',
          color: Colors.white,
          iconSize: 16,
          onPressed: () {
            showSearch(
              context: context,
              delegate:
                  (query == 'logist')
                      ? LogistSearchFilter()
                      : SearchFilter(urlName: query, queries: titleName),
            );
          },
        ),
      ],
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
