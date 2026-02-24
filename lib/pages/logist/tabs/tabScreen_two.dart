// ignore_for_file: file_names
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seyir/main.dart';
import 'package:seyir/pages/logist/detail_page_logist.dart';
import 'package:seyir/widgets/circulateContainer.dart';
import '/utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/utils/models.dart';
import '../../../widgets/text.dart';

// ignore: must_be_immutable
class LogistTabTwoList extends StatefulWidget {
  String filter = '';
  LogistTabTwoList({Key? key, required this.filter}) : super(key: key);
  @override
  State<LogistTabTwoList> createState() => _LogistTabTwoListState();
}

class _LogistTabTwoListState extends State<LogistTabTwoList>
    with SingleTickerProviderStateMixin {
  late List<LogistPageModel> futureDatas = [];
  final control = ScrollController();
  late TabController _tabController;

  int day = now.day;
  int month = now.month;
  int year = now.year;

  int page = 1;
  bool hasMore = true;
  bool isLoading = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    control.addListener(_onScroll);
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    control.removeListener(_onScroll);
    _tabController.dispose();
    control.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LogistTabTwoList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Eger öňki filter bilen täze filter deň däl bolsa, maglumatlary täzeden çek
    if (oldWidget.filter != widget.filter) {
      _loadData(); // Maglumatlary täzeleýän funksiýaňy çagyr
    }
  }

  Future<void> _loadData() async {
    if (!isLoading) {
      isLoading = true;
      final newPageModels = await getData(widget.filter);
      setState(() {
        futureDatas.addAll(newPageModels);
      });
      page++;
      isLoading = false;
    }
  }

  void _onScroll() {
    if (control.position.pixels == control.position.maxScrollExtent) {
      _loadData();
    }
  }

  Future<void> _refreshData() async {
    if (!_isRefreshing) {
      _isRefreshing = true;
      page = 1;
      futureDatas.clear();
      await _loadData();
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              controller: control,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount:
                  isLoading ? futureDatas.length + 1 : futureDatas.length,
              itemBuilder: (context, index) {
                if (index < futureDatas.length) {
                  log('>>>' + futureDatas[index].categoryName);
                  return buildLogistTabTwoModernItemCard(
                    context: context,
                    item: futureDatas[index],
                  );
                } else {
                  return const CircularContainerMain();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLogistTabTwoModernItemCard({
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
        padding: const EdgeInsets.all(8),
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
          ],
        ),
      ),
    );
  }

  bool _isDateValid(String date) {
    final d = DateTime.parse(date);
    return d.isAfter(DateTime.now());
  }

  Future<List<LogistPageModel>> getData(String filter) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/logistika/?checked=True&page=$page$filter&is_client=True',
      ),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List results = data['results'];
      return results.map((e) => LogistPageModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
