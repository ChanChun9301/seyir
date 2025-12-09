// ignore_for_file: file_names

import 'dart:convert';
// import 'dart:developer';
import 'package:seyir/utils/constants.dart';
import '/widgets/text.dart';
import '/widgets/circulateContainer.dart';
import 'detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/utils/models.dart';

class SearchFilter extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: Theme.of(context).colorScheme.background,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 40,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
    );
  }

  String? queries;
  String urlName;
  SearchFilter({required this.urlName, required this.queries})
    : super(
        searchFieldLabel: "Gözle...",
        keyboardType: TextInputType.text,
        searchFieldStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        textInputAction: TextInputAction.search,
      );
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      InkWell(
        child: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.remove, size: 16),
        ),
        onTap: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back, size: 16),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: getSearchData(query),
      builder: (context, AsyncSnapshot<List<PageModel>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DetailPage(
                            id: snapshot.data![index].id,
                            query: urlName,
                            title: snapshot.data![index].title,
                          ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(height(context) / 84.4),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(99, 99, 99, 0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  width: double.infinity,
                  height: 90,
                  margin: EdgeInsets.only(
                    left: height(context) / 84.4,
                    right: height(context) / 84.4,
                    // bottom: 10,
                    top: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
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
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: h / 84.4,
                              right: h / 84.4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BigText(text: snapshot.data![index].title),
                                const SizedBox(height: 5),
                                SmallText(text: snapshot.data![index].desc),
                                SizedBox(height: h / 84.34),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SmallText(
                                      text: snapshot.data![index].categoryName
                                          .toString()
                                          .substring(0, 10),
                                    ),
                                    SmallText(
                                      text: snapshot.data![index].created
                                          .toString()
                                          .substring(0, 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const CircularContainerMain();
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: getSearchData(query),
      builder: (context, AsyncSnapshot<List<PageModel>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DetailPage(
                            id: snapshot.data![index].id,
                            query: urlName,
                            title: snapshot.data![index].title,
                          ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: height(context) / 84.4,
                    right: height(context) / 84.4,
                    // bottom: 10,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(height(context) / 84.4),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(99, 99, 99, 0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  width: double.infinity,
                  height: 90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
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
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                              right: height(context) / 84.4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BigText(text: snapshot.data![index].title),
                                SmallText(text: snapshot.data![index].desc),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SmallText(
                                      text:
                                          snapshot.data![index].categoryName
                                              .toString(),
                                    ),
                                    SmallText(
                                      text:
                                          snapshot.data![index].created
                                              .toString(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const CircularContainerMain();
        }
      },
    );
  }

  Future<List<PageModel>> getSearchData(String text) async {
    final response = await http.get(
      Uri.parse('$baseUrl/${urlName}/?search=$text&checked=true'),
    );
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    List results = data['results'];
    if (response.statusCode == 200) {
      return results.map((e) => PageModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
