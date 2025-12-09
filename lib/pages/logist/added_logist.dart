import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/utils/constants.dart';
import '/utils/models.dart';
import '../../widgets/circulateContainer.dart';
import '../../widgets/text.dart';
import '../../utils/dialogs.dart';
import 'create_logist.dart';
import '/main.dart';
import '/pages/logist/detail_page_logist.dart';

class AddedLogist extends StatefulWidget {
  final String token; // передаём phone, а не token
  const AddedLogist({Key? key, required this.token}) : super(key: key);

  @override
  State<AddedLogist> createState() => _AddedLogistState();
}

class _AddedLogistState extends State<AddedLogist>
    with SingleTickerProviderStateMixin {
  late List<LogistPageModel> futureDatas = [];
  final control = ScrollController();

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
    _loadData();
  }

  Future<void> _loadData() async {
    if (!isLoading && widget.token.isNotEmpty && hasMore) {
      setState(() {
        isLoading = true;
      });

      try {
        final newPageModels = await getAddedLogistData();
        setState(() {
          if (page == 1) {
            futureDatas = newPageModels;
          } else {
            futureDatas.addAll(newPageModels);
          }
          hasMore = newPageModels.isNotEmpty;
          page++;
        });
      } catch (e) {
        debugPrint('Ошибка загрузки данных: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
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
      hasMore = true;
      await _loadData();
      _isRefreshing = false;
    }
  }

  @override
  void dispose() {
    control.removeListener(_onScroll);
    control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        controller: control,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Logistika',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Bricolage',
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    (SeyirApp.tokenNotifier.value == false)
                        ? showAlertDialog(context)
                        : Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreateLog()),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(3),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          futureDatas.isNotEmpty
              ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                    isLoading ? futureDatas.length + 1 : futureDatas.length,
                itemBuilder: (context, index) {
                  if (index >= futureDatas.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: CircularContainerMain(),
                    );
                  }

                  final item = futureDatas[index];

                  int lastday = int.parse(item.lastDate.substring(8, 10));
                  int lastmonth = int.parse(item.lastDate.substring(5, 7));
                  int lastyear = int.parse(item.lastDate.substring(0, 4));

                  return Container(
                    height: 125,
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
                    margin: EdgeInsets.only(
                      left: height(context) / 84.4,
                      right: height(context) / 84.4,
                      top: 10,
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LogistDetailPage(
                                  id: item.id,
                                  title: item.title,
                                ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 150,
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
                              child: Image.network(item.img, fit: BoxFit.cover),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 45,
                                    width: double.infinity,
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              child: BigText(text: item.title),
                                            ),
                                            SmallText(
                                              text:
                                                  (item.created
                                                              .toString()
                                                              .substring(
                                                                0,
                                                                10,
                                                              ) ==
                                                          formattedDate)
                                                      ? 'Şu gün'
                                                      : item.created
                                                          .toString()
                                                          .substring(0, 10),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  showDeleteDialog(
                                                    context,
                                                    'logist',
                                                    item.id,
                                                  );
                                                });
                                              },
                                              icon: Icon(
                                                CupertinoIcons.delete,
                                                size: 14,
                                                color:
                                                    SeyirApp
                                                                .themeNotifier
                                                                .value ==
                                                            ThemeMode.light
                                                        ? Colors.red[600]
                                                        : Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
                                          const SizedBox(width: 5),
                                          Text(
                                            item.lastDate,
                                            style: TextStyle(
                                              color:
                                                  (lastmonth >= month &&
                                                          lastday >= day &&
                                                          lastyear >= year)
                                                      ? Theme.of(
                                                        context,
                                                      ).colorScheme.secondary
                                                      : Colors.red,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Bricolage',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            item.isBring
                                                ? 'Getirmeli'
                                                : 'Alyp gitmeli',
                                            style: TextStyle(
                                              color:
                                                  item.isBring
                                                      ? Colors.green.shade500
                                                      : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Bricolage',
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            item.isBring
                                                ? CupertinoIcons
                                                    .arrow_down_square_fill
                                                : CupertinoIcons
                                                    .arrow_up_square_fill,
                                            size: 18,
                                            color:
                                                item.isBring
                                                    ? Colors.green
                                                    : Colors.blue,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 240,
                                    child: SmallText(text: item.desc),
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
              )
              : Center(
                heightFactor: 2,
                child: Text(
                  'Haryt tapylmady!',
                  style: TextStyle(
                    fontFamily: 'Bricolage',
                    letterSpacing: 3,
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<List<LogistPageModel>> getAddedLogistData() async {
    if (widget.token.isEmpty) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/logistika/added/?author=${widget.token}&page=$page'),
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      final results = data['results'] as List<dynamic>;
      return results.map((e) => LogistPageModel.fromJson(e)).toList();
    }

    return [];
  }
}
