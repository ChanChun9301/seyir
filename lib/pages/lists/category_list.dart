// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seyir/pages/logist/filter_logist_list.dart';
import '/utils/constants.dart';
import '/widgets/circulateContainer.dart';
import '../../component/navbar.dart';
import 'filter_list.dart';
import '/utils/getData.dart';
import '/utils/models.dart';

class CategoryList extends StatefulWidget {
  final String? name;
  final String? pageName;
  const CategoryList({Key? key, required this.name, required this.pageName})
      : super(key: key);
  @override
  State<CategoryList> createState() => _CarCategoryListState();
}

class _CarCategoryListState extends State<CategoryList>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 10,
            centerTitle: true,
            title: const Text(
              'Kategoriýalar',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                  fontFamily: "Bricolage",
                  fontSize: 20,
                  color: Colors.white),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_outward_outlined),
                color: Colors.white,
                iconSize: 20,
                onPressed: () {
                  Navigator.pop(context);
                },
              )
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
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30))),
          )),
      drawer: const NavBar(),
      body: SafeArea(
          child: ListView(children: [
        FutureBuilder(
            future: getDataCategory('${widget.name}'),
            builder: (context, AsyncSnapshot<List<CategoryPage>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    shrinkWrap: true,
                    padding:
                        EdgeInsets.symmetric(horizontal: width(context) / 30),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              snapshot.data![index].title,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Bricolage',
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              if (widget.name == 'logist') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => LogistFilter(
                                              pageName: 'logist',
                                              name: snapshot.data![index].title,
                                              url: 'category',
                                            ))));
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => Filter(
                                              pageName: widget.name,
                                              name: snapshot.data![index].title,
                                              url: 'category',
                                            ))));
                              }
                            },
                          ),
                          const Divider(
                            height: 2,
                            color: Colors.grey,
                          ),
                        ],
                      );
                    });
              } else {
                return const CircularContainerMain();
              }
            })
      ])),
    );
  }
}
