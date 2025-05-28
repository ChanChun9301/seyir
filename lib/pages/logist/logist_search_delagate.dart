// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:seyir/pages/logist/detail_page_logist.dart';
import 'package:seyir/utils/constants.dart';
import '/widgets/text.dart';
import '/widgets/circulateContainer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/utils/models.dart';

class LogistSearchFilter extends SearchDelegate {
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

  LogistSearchFilter()
      : super(
          searchFieldLabel: "Gözle...",
          keyboardType: TextInputType.text,
          searchFieldStyle: const TextStyle(
              fontFamily: "Bricolage",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white),
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

  int day = now.day;
  int month = now.month;
  int year = now.year;

  @override
  Widget buildResults(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: FutureBuilder(
          future: getLogistSearchData(query),
          builder: (context, AsyncSnapshot<List<LogistPageModel>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    int lastday = int.parse(
                        snapshot.data![index].lastDate.substring(8, 10));
                    int lastmonth = int.parse(
                        snapshot.data![index].lastDate.substring(5, 7));
                    int lastyear = int.parse(
                        snapshot.data![index].lastDate.substring(0, 4));
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LogistDetailPage(
                                      id: snapshot.data![index].id,
                                      title: snapshot.data![index].title,
                                    )));
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
                                offset: Offset(
                                  0,
                                  2,
                                ),
                              ),
                            ],
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          width: double.infinity,
                          height: 90,
                          margin: EdgeInsets.only(
                              left: height(context) / 84.4,
                              right: height(context) / 84.4,
                              // bottom: 10,
                              top: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 110,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(h / 84.4),
                                        bottomLeft: Radius.circular(h / 84.4)),
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
                                      )),
                                ),
                                Expanded(
                                  child: SizedBox(
                                      child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 5,
                                              right: height(context) / 84.4),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                BigText(
                                                    text: snapshot
                                                        .data![index].title),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SmallText(
                                                            text: (snapshot
                                                                        .data![
                                                                            index]
                                                                        .created
                                                                        .toString()
                                                                        .substring(
                                                                            0,
                                                                            10) ==
                                                                    formattedDate)
                                                                ? 'Şu gün'
                                                                : snapshot
                                                                    .data![
                                                                        index]
                                                                    .created
                                                                    .toString()
                                                                    .substring(
                                                                        0, 10)),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text('Ahyrky sene:',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Bricolage',
                                                              fontSize: 10,
                                                            )),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                            (snapshot
                                                                        .data![
                                                                            index]
                                                                        .created
                                                                        .toString()
                                                                        .substring(
                                                                            0,
                                                                            10) !=
                                                                    formattedDate
                                                                        .toString())
                                                                ? snapshot
                                                                    .data![
                                                                        index]
                                                                    .lastDate
                                                                    .toString()
                                                                : snapshot
                                                                    .data![
                                                                        index]
                                                                    .lastDate
                                                                    .toString(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: (lastmonth >= month &&
                                                                      lastday >=
                                                                          day &&
                                                                      lastyear >=
                                                                          year)
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary
                                                                  : Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily:
                                                                  'Bricolage',
                                                              fontSize: 10,
                                                            )),
                                                        Icon(
                                                          (snapshot.data![index]
                                                                      .isBring ==
                                                                  true)
                                                              ? CupertinoIcons
                                                                  .arrow_down_square_fill
                                                              : CupertinoIcons
                                                                  .arrow_up_square_fill,
                                                          size: 16,
                                                          color: (snapshot
                                                                      .data![
                                                                          index]
                                                                      .isBring ==
                                                                  true)
                                                              ? Colors.green
                                                              : Colors.blue,
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SmallText(
                                                    text: snapshot
                                                        .data![index].desc),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text('Nirden:',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Bricolage',
                                                          fontSize: 10,
                                                        )),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    SmallText(
                                                        text: snapshot
                                                            .data![index].nirden
                                                            .toString()),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text('Nirä:',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Bricolage',
                                                          fontSize: 10,
                                                        )),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    SmallText(
                                                        text: snapshot
                                                            .data![index].where
                                                            .toString()),
                                                  ],
                                                ),
                                              ]))),
                                ),
                              ])),
                    );
                  });
            } else {
              return const CircularContainerMain();
            }
          }),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: FutureBuilder(
          future: getLogistSearchData(query),
          builder: (context, AsyncSnapshot<List<LogistPageModel>> snapshot) {
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
                                builder: (context) => LogistDetailPage(
                                      id: snapshot.data![index].id,
                                      title: snapshot.data![index].title,
                                    )));
                      },
                      child: Container(
                          margin: EdgeInsets.only(
                              left: height(context) / 84.4,
                              right: height(context) / 84.4,
                              // bottom: 10,
                              top: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(height(context) / 84.4),
                            ),
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
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          width: double.infinity,
                          height: 115,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 150,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(h / 84.4),
                                        bottomLeft: Radius.circular(h / 84.4)),
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
                                      )),
                                ),
                                Expanded(
                                  child: SizedBox(
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                          ),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
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
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text('Ahyrky sene:',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Bricolage',
                                                              fontSize: 10,
                                                            )),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                            (snapshot
                                                                        .data![
                                                                            index]
                                                                        .created
                                                                        .toString()
                                                                        .substring(
                                                                            0,
                                                                            10) !=
                                                                    formattedDate
                                                                        .toString())
                                                                ? snapshot
                                                                    .data![
                                                                        index]
                                                                    .lastDate
                                                                    .toString()
                                                                : snapshot
                                                                    .data![
                                                                        index]
                                                                    .lastDate
                                                                    .toString(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: (int.parse(snapshot.data![index].lastDate.substring(5, 7)) >= month &&
                                                                      int.parse(snapshot.data![index].lastDate.substring(8,
                                                                              10)) >=
                                                                          day &&
                                                                      int.parse(snapshot.data![index].lastDate.substring(
                                                                              0,
                                                                              4)) >=
                                                                          year)
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary
                                                                  : Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily:
                                                                  'Bricolage',
                                                              fontSize: 10,
                                                            )),
                                                      ],
                                                    ),
                                                    Icon(
                                                      (snapshot.data![index]
                                                                  .isBring ==
                                                              true)
                                                          ? CupertinoIcons
                                                              .arrow_down_square_fill
                                                          : CupertinoIcons
                                                              .arrow_up_square_fill,
                                                      size: 16,
                                                      color: (snapshot
                                                                  .data![index]
                                                                  .isBring ==
                                                              true)
                                                          ? Colors.green
                                                          : Colors.blue,
                                                    )
                                                  ],
                                                ),
                                                Text(snapshot.data![index].desc,
                                                    maxLines: 1,
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
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text('Nirden:',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Bricolage',
                                                          fontSize: 10,
                                                        )),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    SmallText(
                                                        text: snapshot
                                                            .data![index].nirden
                                                            .toString()),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Nirä:',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Bricolage',
                                                              fontSize: 10,
                                                            )),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        SmallText(
                                                            text: snapshot
                                                                .data![index]
                                                                .where
                                                                .toString()),
                                                      ],
                                                    ),
                                                    snapshot.data![index]
                                                                .checked ==
                                                            true
                                                        ? const SmallText(
                                                            text: '')
                                                        : const Text(
                                                            'Kabul edilmedik',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .redAccent,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily:
                                                                  'Bricolage',
                                                              fontSize: 10,
                                                            )),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: 160,
                                                      child: SmallText(
                                                          text: snapshot
                                                              .data![index]
                                                              .categoryName
                                                              .toString()),
                                                    ),
                                                    SmallText(
                                                        text: (snapshot
                                                                    .data![
                                                                        index]
                                                                    .created
                                                                    .toString()
                                                                    .substring(
                                                                        0,
                                                                        10) ==
                                                                formattedDate
                                                                    .toString())
                                                            ? 'Şu gün'
                                                            : snapshot
                                                                .data![index]
                                                                .created
                                                                .toString()
                                                                .substring(
                                                                    0, 10)),
                                                  ],
                                                ),
                                              ]))),
                                ),
                              ])),
                    );
                  });
            } else {
              return const CircularContainerMain();
            }
          }),
    );
  }

  Future<List<LogistPageModel>> getLogistSearchData(String text) async {
    final response = await http
        .get(Uri.parse('$baseUrl/logistmain-list/?search=$text&checked=true'));
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    List results = data['results'];
    log(data.length.toString());
    if (response.statusCode == 200) {
      return results.map((e) => LogistPageModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
