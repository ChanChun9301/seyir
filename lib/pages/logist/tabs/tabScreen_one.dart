// ignore_for_file: file_names
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seyir/main.dart';
import 'package:seyir/pages/logist/detail_page_logist.dart';
import 'package:seyir/pages/logist/logist_search_delagate.dart';
import 'package:seyir/widgets/circulateContainer.dart';
import 'package:seyir/widgets/filterWidget.dart';
import '/component/listAppbar.dart';
import '/utils/constants.dart';
import '../../../component/navbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/utils/models.dart';
import '../../../widgets/text.dart';

// ignore: must_be_immutable
class LogistTabOneList extends StatefulWidget {
  String filter = '';
  LogistTabOneList({Key? key, required this.filter}) : super(key: key);
  @override
  State<LogistTabOneList> createState() => _LogistTabOneListState();
}

class _LogistTabOneListState extends State<LogistTabOneList>
    with SingleTickerProviderStateMixin {
  late List<LogistCarPageModel> futureDatas = [];
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
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: LogistSearchFilter(),
                      );
                    },
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    label: Text(
                      'Gözle',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogistFilterWidget(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.sort,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    label: Text(
                      'Filter',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              controller: control,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount:
                  isLoading ? futureDatas.length + 1 : futureDatas.length,
              itemBuilder: (context, index) {
                if (index < futureDatas.length) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => LogistDetailPage(
                                id: futureDatas[index].id,
                                title: futureDatas[index].title,
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
                      margin: EdgeInsets.only(
                        left: height(context) / 84.4,
                        right: height(context) / 84.4,
                      ),
                      width: double.infinity,
                      height: 85,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 110,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                  height(context) / 84.4,
                                ),
                                bottomLeft: Radius.circular(
                                  height(context) / 84.4,
                                ),
                              ),
                              color: Colors.white38,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                  height(context) / 84.4,
                                ),
                                bottomLeft: Radius.circular(
                                  height(context) / 84.4,
                                ),
                              ),
                              child: Image.network(
                                (futureDatas[index].img != '')
                                    ? futureDatas[index].img
                                    : 'assets/no-image.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      futureDatas[index].title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Bricolage',
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      removeHtmlTags(futureDatas[index].desc),

                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Bricolage',
                                        fontSize: 10,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: SmallText(
                                            text:
                                                futureDatas[index].categoryName
                                                    .toString(),
                                          ),
                                        ),
                                        SmallText(
                                          text:
                                              (futureDatas[index].created
                                                          .toString()
                                                          .substring(0, 10) ==
                                                      formattedDate.toString())
                                                  ? 'Şu gün'
                                                  : futureDatas[index].created
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

  Future<List<LogistCarPageModel>> getData(String filter) async {
    final response = await http.get(
      Uri.parse('$baseUrl/logistcarmain-list/?checked=True&page=$page$filter'),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List results = data['results'];
      return results.map((e) => LogistCarPageModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
