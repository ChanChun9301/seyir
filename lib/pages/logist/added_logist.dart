import 'dart:convert';
// import 'dart:developer';
import '/main.dart';
import '/pages/logist/detail_page_logist.dart';
import '/utils/constants.dart';
import 'create_logist.dart';
import '../../utils/dialogs.dart';
import '../../widgets/circulateContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/utils/models.dart';
import '../../widgets/text.dart';

class AddedLogist extends StatefulWidget {
  final String token;
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
    if (!isLoading) {
      isLoading = true;
      final newPageModels = await getAddedLogistData(widget.token);
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
                  int lastday = int.parse(
                    futureDatas[index].lastDate.substring(8, 10),
                  );
                  int lastmonth = int.parse(
                    futureDatas[index].lastDate.substring(5, 7),
                  );
                  int lastyear = int.parse(
                    futureDatas[index].lastDate.substring(0, 4),
                  );

                  if (index < futureDatas.length) {
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
                                    id: futureDatas[index].id,
                                    title: futureDatas[index].title,
                                  ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                child: Image.network(
                                  futureDatas[index].img,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                  top: 5,
                                ),
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
                                                child: BigText(
                                                  text:
                                                      futureDatas[index].title,
                                                ),
                                              ),
                                              SmallText(
                                                text:
                                                    (futureDatas[index].created
                                                                .toString()
                                                                .substring(
                                                                  0,
                                                                  10,
                                                                ) ==
                                                            formattedDate)
                                                        ? 'Şu gün'
                                                        : futureDatas[index]
                                                            .created
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
                                                      futureDatas[index].id,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              (futureDatas[index].created
                                                          .toString()
                                                          .substring(0, 10) !=
                                                      formattedDate.toString())
                                                  ? futureDatas[index].lastDate
                                                      .toString()
                                                  : futureDatas[index].lastDate
                                                      .toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                              (futureDatas[index].isBring ==
                                                      true)
                                                  ? 'Getirmeli'
                                                  : 'Alyp gitmeli',
                                              style: TextStyle(
                                                color:
                                                    (futureDatas[index]
                                                                .isBring ==
                                                            true)
                                                        ? (SeyirApp
                                                                    .themeNotifier
                                                                    .value ==
                                                                ThemeMode.light
                                                            ? Colors
                                                                .green
                                                                .shade500
                                                            : Colors
                                                                .grey
                                                                .shade200)
                                                        : Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Bricolage',
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(
                                              (futureDatas[index].isBring ==
                                                      true)
                                                  ? CupertinoIcons
                                                      .arrow_down_square_fill
                                                  : CupertinoIcons
                                                      .arrow_up_square_fill,
                                              size: 18,
                                              color:
                                                  (futureDatas[index].isBring ==
                                                          true)
                                                      ? Colors.green
                                                      : Colors.blue,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 240,
                                      child: SmallText(
                                        text: futureDatas[index].desc,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        SmallText(
                                          text:
                                              futureDatas[index].nirden
                                                  .toString(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
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
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            SmallText(
                                              text:
                                                  futureDatas[index].where
                                                      .toString(),
                                            ),
                                          ],
                                        ),
                                        futureDatas[index].checked == true
                                            ? const SmallText(text: '')
                                            : const Text(
                                              'Kabul edilmedik',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Bricolage',
                                                fontSize: 12,
                                              ),
                                            ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: CircularContainerMain(),
                    );
                  }
                },
              )
              : Center(
                heightFactor: height(context) / 56.23,
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

  Future<List<LogistPageModel>> getAddedLogistData(String gettoken) async {
    // isLoading = true;
    final response = await http.get(
      Uri.parse('$baseUrl/logist-added-list/?author=$gettoken&page=$page'),
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
