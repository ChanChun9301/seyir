// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'package:seyir/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:seyir/pages/logist/detail_page_logist.dart';
import 'package:seyir/pages/logist/create/logistaddress.dart';
import 'package:seyir/pages/logist/create/logistcategory.dart';

import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';
import '/widgets/text.dart';

class LogistSearchFilter extends SearchDelegate {
  /// ================= FILTER STATE =================
  List<SaylananCategory> selectedCategories = [];
  List<SaylananSalgy> selectedAddresses = [];

  bool bring = false;
  bool get = false;

  TextEditingController minPrice = TextEditingController();
  TextEditingController maxPrice = TextEditingController();

  LogistSearchFilter()
    : super(
        searchFieldLabel: "Gözle...",
        keyboardType: TextInputType.text,
        searchFieldStyle: const TextStyle(
          fontFamily: "Bricolage",
          fontSize: 16,
          color: Colors.white,
        ),
        textInputAction: TextInputAction.search,
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 40,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
    );
  }

  /// ================= APPBAR BUTTONS =================
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.filter_alt_outlined, size: 18),
        onPressed: () async {
          await _openFilterSheet(context);
          showSuggestions(context);
        },
      ),
      IconButton(
        icon: const Icon(Icons.clear, size: 16),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, size: 16),
      onPressed: () => close(context, null),
    );
  }

  /// ================= FILTER SHEET =================
  Future<void> _openFilterSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// CATEGORY
                    ListTile(
                      title: const Text('Kategoriýa'),
                      subtitle: Text(
                        selectedCategories.map((e) => e.name).join(', '),
                      ),
                      onTap: () async {
                        final result =
                            await Navigator.push<List<SaylananCategory>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LogistCategoryPage(),
                              ),
                            );
                        if (result != null) {
                          setModalState(() => selectedCategories = result);
                        }
                      },
                    ),

                    /// ADDRESS
                    ListTile(
                      title: const Text('Salgy'),
                      subtitle: Text(
                        selectedAddresses.map((e) => e.name).join(', '),
                      ),
                      onTap: () async {
                        final result =
                            await Navigator.push<List<SaylananSalgy>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LogistAddressPage(),
                              ),
                            );
                        if (result != null) {
                          setModalState(() => selectedAddresses = result);
                        }
                      },
                    ),

                    /// PRICE
                    TextField(
                      controller: minPrice,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min bahasy',
                      ),
                    ),
                    TextField(
                      controller: maxPrice,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max bahasy',
                      ),
                    ),

                    /// SWITCHES
                    SwitchListTile(
                      title: const Text('Getirmeli'),
                      value: bring,
                      onChanged: (v) {
                        setModalState(() {
                          bring = v;
                          if (v) get = false;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Alyp gitmeli'),
                      value: get,
                      onChanged: (v) {
                        setModalState(() {
                          get = v;
                          if (v) bring = false;
                        });
                      },
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// ================= QUERY BUILDER =================
  String _buildQuery() {
    List<String> parts = [];

    if (query.isNotEmpty) parts.add('search=$query');

    if (minPrice.text.isNotEmpty) {
      parts.add('min=${minPrice.text}');
    }

    if (maxPrice.text.isNotEmpty) {
      parts.add('max=${maxPrice.text}');
    }

    if (selectedCategories.isNotEmpty) {
      parts.add('category=${selectedCategories.map((e) => e.id).join(',')}');
    }

    if (selectedAddresses.isNotEmpty) {
      parts.add('address=${selectedAddresses.map((e) => e.id).join(',')}');
    }

    if (bring) parts.add('bring=true');
    if (get) parts.add('bring=false');

    parts.add('checked=true');

    return parts.join('&');
  }

  /// ================= API =================
  Future<List<LogistPageModel>> _fetchData() async {
    final url = '$baseUrl/logistika/?${_buildQuery()}';
    log('REQUEST: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data['results'] as List)
          .map((e) => LogistPageModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed: ${response.statusCode}');
    }
  }

  /// ================= RESULTS & SUGGESTIONS =================
  @override
  Widget buildResults(BuildContext context) => _buildList(context: context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context: context);

  Widget _buildList({required BuildContext context}) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: FutureBuilder<List<LogistPageModel>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('Netije tapylmady'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return buildLogistModernItemCard(context: context, item: item);
            },
          );
        },
      ),
    );
  }

  Widget buildLogistModernItemCard({
    required BuildContext context,
    required LogistPageModel item,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LogistDetailPage(id: item.id, title: item.title),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: height(context) / 84.4,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(99, 99, 99, 0.18),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// IMAGE
            Hero(
              tag: 'logist-two-${item.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.img.isNotEmpty ? item.img : 'assets/no-image.jpg',
                  width: 90,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// CONTENT
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
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Bricolage',
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// DEADLINE + TYPE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Ahyrky sene:',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Bricolage',
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.lastDate,
                            style: TextStyle(
                              color:
                                  _isDateValid(item.lastDate)
                                      ? theme.colorScheme.secondary
                                      : Colors.red,
                              fontFamily: 'Bricolage',
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            item.isBring ? 'Getirmeli' : 'Alyp gitmeli',
                            style: TextStyle(
                              color:
                                  item.isBring
                                      ? (SeyirApp.themeNotifier.value ==
                                              ThemeMode.light
                                          ? Colors.green.shade500
                                          : Colors.grey.shade200)
                                      : Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Bricolage',
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            item.isBring
                                ? CupertinoIcons.arrow_down_square_fill
                                : CupertinoIcons.arrow_up_square_fill,
                            size: 18,
                            color: item.isBring ? Colors.green : Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// DESCRIPTION
                  Text(
                    removeHtmlTags(item.desc),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.onSecondary,
                      fontFamily: 'Bricolage',
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// FROM
                  Row(
                    children: [
                      Text(
                        'Nirden:',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Bricolage',
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: SmallText(text: item.nirden)),
                    ],
                  ),

                  /// TO + STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Nirä:',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Bricolage',
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 120,
                            child: SmallText(text: item.where),
                          ),
                        ],
                      ),
                      item.checked
                          ? const SizedBox()
                          : const Text(
                            'Kabul edilmedik',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontFamily: 'Bricolage',
                              fontSize: 10,
                            ),
                          ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// CATEGORY + DATE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: SmallText(text: item.categoryName),
                      ),
                      SmallText(
                        text:
                            item.created.toString().substring(0, 10) ==
                                    formattedDate
                                ? 'Şu gün'
                                : item.created.toString().substring(0, 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ARROW
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

  bool _isDateValid(String date) {
    final d = DateTime.parse(date);
    return d.isAfter(DateTime.now());
  }
}
