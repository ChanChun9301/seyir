// ignore_for_file: file_names

import 'dart:convert';
// import 'dart:developer';
import 'package:seyir/utils/constants.dart';
import '/widgets/text.dart';
import '/widgets/circulateContainer.dart';
import 'detail/detail_page.dart';
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
    return FutureBuilder(
      future: getSearchData(query),
      builder: (context, AsyncSnapshot<List<PageModel>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildModernListItem(snapshot.data![index], context);
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
              return _buildModernListItem(snapshot.data![index], context);
            },
          );
        } else {
          return const CircularContainerMain();
        }
      },
    );
  }

  Widget _buildModernListItem(PageModel item, BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    DetailPage(id: item.id, query: urlName, title: item.title),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'item-${item.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  item.img.isNotEmpty ? item.img : '',
                  width: 90,
                  height: 110,
                  fit: BoxFit.cover,
                  // Eger URL boş bolsa ýa-da surat ýüklenmese işleýär
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/no-image.jpg',
                      width: 90,
                      height: 110,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: theme.colorScheme.secondary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// DESCRIPTION
                  Text(
                    item.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// ADDRESS + CATEGORY + DATE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallText(text: item.addressName ?? '-'),

                      SizedBox(
                        width: 60,
                        child: SmallText(text: item.categoryName ?? ""),
                      ),

                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 13),
                          const SizedBox(width: 4),
                          SmallText(
                            text:
                                (item.created.toString().substring(0, 10) ==
                                        formattedDate)
                                    ? "Şu gün"
                                    : item.created.toString().substring(0, 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
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
