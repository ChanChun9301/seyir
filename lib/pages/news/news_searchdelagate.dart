// ignore_for_file: file_names

import 'dart:convert';
import 'package:seyir/utils/constants.dart';
import 'package:seyir/widgets/text.dart';
import '/pages/news/news_detailpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/utils/models.dart';

class NewsSearchFilter extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      ),
    );
  }

  NewsSearchFilter()
      : super(
          searchFieldLabel: "Gözle...",
          searchFieldStyle: const TextStyle(
              fontFamily: 'Bricolage',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      InkWell(
        child: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(
            Icons.remove,
            size: 16,
          ),
        ),
        onTap: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(
        Icons.arrow_back,
        size: 16,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: getData(query),
        builder: (context, AsyncSnapshot<List<NewsPage>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewsDetailPage(
                                      title: snapshot.data![index].title,
                                      id: snapshot.data![index].id,
                                    )));
                      },
                      child: Container(
                          margin: EdgeInsets.only(
                              left: h / 84.4, right: h / 84.4, top: h / 84.4),
                          width: double.infinity,
                          height: 75,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(h / 84.4)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(99, 99, 99, 0.2),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: Offset(
                                    0,
                                    2,
                                  ),
                                ),
                              ],
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                          child: Row(children: [
                            Container(
                              width: width(context) / 6,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(h / 84.4),
                                  bottomLeft: Radius.circular(h / 84.4),
                                ),
                                color: Colors.white38,
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(h / 84.4),
                                    bottomLeft: Radius.circular(h / 84.4),
                                  ),
                                  child: Image.network(
                                    snapshot.data![index].img,
                                    fit: BoxFit.fill,
                                  )),
                            ),
                            Expanded(
                              child: SizedBox(
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          left: height(context) / 84.4,
                                          right: height(context) / 84.4),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(snapshot.data![index].title,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Bricolage',
                                                  fontSize: 14,
                                                )),
                                            const SizedBox(height: 5),
                                            Text(snapshot.data![index].desc,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Bricolage',
                                                  fontSize: 12,
                                                )),
                                            SizedBox(height: h / 84.34),
                                            SmallText(
                                                text: (snapshot.data![index]
                                                            .created
                                                            .toString()
                                                            .substring(0, 10) ==
                                                        formattedDate)
                                                    ? 'Şu gün'
                                                    : snapshot
                                                        .data![index].created
                                                        .toString()
                                                        .substring(0, 10)),
                                          ]))),
                            ),
                          ])));
                });
          } else {
            return const Center(
              child: Text(
                "Gözleg tapylmady!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
              ),
            );
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: getData(query),
        builder: (context, AsyncSnapshot<List<NewsPage>> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewsDetailPage(
                                          title: snapshot.data![index].title,
                                          id: snapshot.data![index].id,
                                        )));
                          },
                          child: Container(
                              margin: EdgeInsets.only(
                                  left: h / 84.4,
                                  right: h / 84.4,
                                  top: h / 84.4),
                              width: double.infinity,
                              height: 75,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(h / 84.4)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(99, 99, 99, 0.2),
                                      blurRadius: 8,
                                      spreadRadius: 0,
                                      offset: Offset(
                                        0,
                                        2,
                                      ),
                                    ),
                                  ],
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              child: Row(children: [
                                Container(
                                  width: 110,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(h / 84.4),
                                      bottomLeft: Radius.circular(h / 84.4),
                                    ),
                                    color: Colors.white38,
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(h / 84.4),
                                        bottomLeft: Radius.circular(h / 84.4),
                                      ),
                                      child: Image.network(
                                        snapshot.data![index].img,
                                        fit: BoxFit.fill,
                                      )),
                                ),
                                Expanded(
                                  child: SizedBox(
                                      child: Padding(
                                          padding: EdgeInsets.only(
                                              left: height(context) / 84.4,
                                              right: height(context) / 84.4),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    snapshot.data![index].title,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Bricolage',
                                                      fontSize: 12,
                                                    )),
                                                Text(snapshot.data![index].desc,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSecondary,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'Bricolage',
                                                      fontSize: 10,
                                                    )),
                                                SmallText(
                                                    text: (snapshot.data![index]
                                                                .created
                                                                .toString()
                                                                .substring(
                                                                    0, 10) ==
                                                            formattedDate)
                                                        ? 'Şu gün'
                                                        : snapshot.data![index]
                                                            .created
                                                            .toString()
                                                            .substring(0, 10)),
                                              ]))),
                                ),
                              ])));
                    })
                : const Center(
                    child: Text(
                      "Gözleg tapylmady!",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  );
          } else {
            return const Center(
              child: Text(
                "Gözleg tapylmady!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
              ),
            );
          }
        });
  }

  Future<List<NewsPage>> getData(String text) async {
    final response = await http
        .get(Uri.parse('$baseUrl/news-list/?search=$text&checked=true'));
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    List results = data['results'];
    if (response.statusCode == 200) {
      return results.map((e) => NewsPage.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
