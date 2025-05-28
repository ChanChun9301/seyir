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
            fontSize: 20,
            color: Colors.white),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search_outlined),
          tooltip: 'Gözle',
          color: Colors.white,
          iconSize: 20,
          onPressed: () {
            showSearch(
                context: context,
                delegate: (query == 'logist')
                    ? LogistSearchFilter()
                    : SearchFilter(urlName: query, queries: titleName));
          },
        ),
        PopupMenuButton(
            color: Theme.of(context).colorScheme.primaryContainer,
            icon: const Icon(Icons.filter_list),
            iconSize: 20,
            tooltip: 'Tertiple',
            padding: const EdgeInsets.all(2),
            itemBuilder: (context) {
              return [
                PopupMenuItem<int>(
                  value: 0,
                  child: Text(
                    "Salgylar",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Bricolage',
                      fontSize: 14,
                    ),
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Text(
                    (query == 'logist') ? 'Filter' : "Kategoriýalar",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Bricolage',
                      fontSize: 14,
                    ),
                  ),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 0) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddressList(name: query)));
              } else if (value == 1) {
                (query == 'logist')
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LogistFilterWidget()))
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CategoryList(
                                  pageName: titleName,
                                  name: query,
                                )));
              }
            }),
      ],
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(
              Icons.sort_outlined,
              color: Colors.white,
              size: 20,
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
