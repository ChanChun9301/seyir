// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:seyir/pages/logist/detail_page_logist.dart';
import 'package:seyir/utils/constants.dart'; // Assuming this contains baseUrl, now, formattedDate
import '/widgets/text.dart'; // Assuming this contains BigText and SmallText
import '/widgets/circulateContainer.dart'; // Assuming this contains CircularContainerMain
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/utils/models.dart'; // Assuming this contains LogistPageModel

class LogistSearchFilter extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      // colorScheme: Theme.of(context).colorScheme.background ,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 40,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
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
          color: Colors.white,
        ),
        textInputAction: TextInputAction.search,
      );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      InkWell(
        onTap: () {
          query = "";
        },
        child: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(
            Icons.clear,
            size: 16,
          ), // Changed to clear icon for better UX
        ),
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

  // Renamed for clarity, although these are standard Dart getters for DateTime
  int get currentDay => now.day;
  int get currentMonth => now.month;
  int get currentYear => now.year;

  @override
  Widget buildResults(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double borderRadiusValue = screenHeight / 84.4;
    const double cardHeight = 90; // Defined as a constant

    return FutureBuilder(
      future: getLogistSearchData(query),
      builder: (context, AsyncSnapshot<List<LogistPageModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          ); // Show loading indicator
        } else if (snapshot.hasError) {
          log('Error fetching data: ${snapshot.error}');
          return Center(
            child: Text('Error: ${snapshot.error}'),
          ); // Display error
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found.')); // No data
        } else {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final logistItem = snapshot.data![index];
              final DateTime lastDate = DateTime.parse(
                logistItem.lastDate,
              ); // Parse once
              final DateTime createdDate = DateTime.parse(
                logistItem.createdString,
              );

              // More robust date comparison
              final bool isLastDateValid =
                  lastDate.isAfter(now) || lastDate.isAtSameMomentAs(now);

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => LogistDetailPage(
                            id: logistItem.id,
                            title: logistItem.title,
                          ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadiusValue),
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
                  height: cardHeight,
                  margin: EdgeInsets.only(
                    left: borderRadiusValue,
                    right: borderRadiusValue,
                    top: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 110,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadiusValue),
                            bottomLeft: Radius.circular(borderRadiusValue),
                          ),
                          color: Colors.white38,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadiusValue),
                            bottomLeft: Radius.circular(borderRadiusValue),
                          ),
                          child: Image.network(
                            logistItem.img,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ); // Error placeholder
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        // Removed redundant SizedBox
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: borderRadiusValue,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BigText(text: logistItem.title),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SmallText(
                                    text:
                                        (createdDate
                                                    .toLocal()
                                                    .toString()
                                                    .substring(0, 10) ==
                                                formattedDate)
                                            ? 'Şu gün'
                                            : createdDate
                                                .toLocal()
                                                .toString()
                                                .substring(0, 10),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Ahyrky sene:',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Bricolage',
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        logistItem.lastDate,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              isLastDateValid
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.secondary
                                                  : Colors.red,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Bricolage',
                                          fontSize: 10,
                                        ),
                                      ),
                                      Icon(
                                        logistItem.isBring
                                            ? CupertinoIcons
                                                .arrow_down_square_fill
                                            : CupertinoIcons
                                                .arrow_up_square_fill,
                                        size: 16,
                                        color:
                                            logistItem.isBring
                                                ? Colors.green
                                                : Colors.blue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SmallText(text: removeHtmlTags(logistItem.desc)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nirden:',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Bricolage',
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  SmallText(text: logistItem.nirden.toString()),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nirä:',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Bricolage',
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  SmallText(text: logistItem.where.toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double borderRadiusValue = screenHeight / 84.4;
    const double cardHeight = 115; // Defined as a constant

    return FutureBuilder(
      future: getLogistSearchData(query),
      builder: (context, AsyncSnapshot<List<LogistPageModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          ); // Show loading indicator
        } else if (snapshot.hasError) {
          log('Error fetching data: ${snapshot.error}');
          return Center(
            child: Text('Error: ${snapshot.error}'),
          ); // Display error
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No suggestions found.')); // No data
        } else {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final logistItem = snapshot.data![index];
              final DateTime lastDate = DateTime.parse(
                logistItem.lastDate,
              ); // Parse once
              final DateTime createdDate = DateTime.parse(
                logistItem.createdString,
              );

              // More robust date comparison
              final bool isLastDateValid =
                  lastDate.isAfter(now) || lastDate.isAtSameMomentAs(now);

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => LogistDetailPage(
                            id: logistItem.id,
                            title: logistItem.title,
                          ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: borderRadiusValue,
                    right: borderRadiusValue,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadiusValue),
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
                  height: cardHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 110,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadiusValue),
                            bottomLeft: Radius.circular(borderRadiusValue),
                          ),
                          color: Colors.white38,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadiusValue),
                            bottomLeft: Radius.circular(borderRadiusValue),
                          ),
                          child: Image.network(
                            logistItem.img,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ); // Error placeholder
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        // Removed redundant SizedBox
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                logistItem.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Bricolage',
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Ahyrky sene:',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Bricolage',
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        logistItem.lastDate,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              isLastDateValid
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.secondary
                                                  : Colors.red,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Bricolage',
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    logistItem.isBring
                                        ? CupertinoIcons.arrow_down_square_fill
                                        : CupertinoIcons.arrow_up_square_fill,
                                    size: 16,
                                    color:
                                        logistItem.isBring
                                            ? Colors.green
                                            : Colors.blue,
                                  ),
                                ],
                              ),
                              Text(
                                removeHtmlTags(logistItem.desc),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Bricolage',
                                  fontSize: 10,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nirden:',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Bricolage',
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  SmallText(text: logistItem.nirden.toString()),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nirä:',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Bricolage',
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      SmallText(
                                        text: logistItem.where.toString(),
                                      ),
                                    ],
                                  ),
                                  if (logistItem.checked ==
                                      false) // Only show if not checked
                                    const Text(
                                      'Kabul edilmedik',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Bricolage',
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 160,
                                    child: SmallText(
                                      text: logistItem.categoryName.toString(),
                                    ),
                                  ),
                                  SmallText(
                                    text:
                                        (createdDate
                                                    .toLocal()
                                                    .toString()
                                                    .substring(0, 10) ==
                                                formattedDate)
                                            ? 'Şu gün'
                                            : createdDate
                                                .toLocal()
                                                .toString()
                                                .substring(0, 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<List<LogistPageModel>> getLogistSearchData(String text) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/logistmain-list/?search=$text&checked=true'),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        List results = data['results'];
        log('Fetched ${results.length} results for query: $text');
        return results.map((e) => LogistPageModel.fromJson(e)).toList();
      } else {
        log('Failed to load data: ${response.statusCode}');
        // You might want to throw an exception or return an empty list based on your error handling strategy
        throw Exception(
          'Failed to load logist search data: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('Error in getLogistSearchData: $e');
      throw Exception('Error fetching logist data: $e');
    }
  }
}
