// ignore_for_file: unnecessary_import
import 'dart:convert';
import 'package:seyir/pages/create/create_prod.dart';
import 'package:seyir/pages/detail_page.dart';
import '/main.dart';
import '/utils/constants.dart';
import '../../utils/dialogs.dart';
import '../../widgets/circulateContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/utils/models.dart';
import '../text.dart';

class AddedOtherWidget extends StatefulWidget {
  final String token;
  const AddedOtherWidget({Key? key, required this.token}) : super(key: key);
  @override
  State<AddedOtherWidget> createState() => _AddedOtherWidgetState();
}

class _AddedOtherWidgetState extends State<AddedOtherWidget>
    with SingleTickerProviderStateMixin {
  late List<PageModel> futureDatas = [];

  final control = ScrollController();

  int page = 1;
  bool hasMore = true;
  bool isLoading = false;
  bool _isRefreshing = false;

  int day = now.day;
  int month = now.month;
  int year = now.year;

  @override
  void initState() {
    super.initState();
    control.addListener(_onScroll);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!isLoading) {
      isLoading = true;
      final newPageModels = await getAddedData();
      if (mounted) {
        setState(() {
          futureDatas.addAll(newPageModels);
        });
      }
      page++;
      isLoading = false;
    }
  }

  void _onScroll() {
    if (control.position.pixels == control.position.maxScrollExtent) {
      _loadData();
    }
  }

  @override
  void dispose() {
    control.removeListener(_onScroll);
    control.dispose();
    super.dispose();
  }

  Future<List<PageModel>> getAddedData() async {
    final response = await http.get(Uri.parse(
        '$baseUrl/other-added-list/?author=${widget.token}&page=$page'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List results = data['results'];
      return results.map((e) => PageModel.fromJson(e)).toList();
    } else {
      return [];
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
      child: ListView(
        controller: control,
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Beýlekiler',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Bricolage',
                          fontSize: 16,
                        )),
                    ElevatedButton(
                        onPressed: () {
                          (SeyirApp.tokenNotifier.value == false)
                              ? showAlertDialog(context)
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const CreateProd(
                                            title: 'Beýlekiler',
                                            query: 'other',
                                          )));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(3)),
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 16,
                        ))
                  ])),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: futureDatas.length,
              itemBuilder: (context, index) {
                if (index < futureDatas.length) {
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailPage(
                                      id: futureDatas[index].id,
                                      query: 'other',
                                      title: futureDatas[index].title,
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
                              bottom: 0,
                              top: 10),
                          child: Row(children: [
                            Container(
                              width: 150,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft:
                                      Radius.circular(height(context) / 84.4),
                                  bottomLeft:
                                      Radius.circular(height(context) / 84.4),
                                ),
                                color: Colors.white38,
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft:
                                        Radius.circular(height(context) / 84.4),
                                    bottomLeft:
                                        Radius.circular(height(context) / 84.4),
                                  ),
                                  child: Image.network(
                                    futureDatas[index].img,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 10, top: 5),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            height: 45,
                                            child: Stack(children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 150,
                                                    child: BigText(
                                                        text: futureDatas[index]
                                                            .title),
                                                  ),
                                                  SizedBox(
                                                    width: 150,
                                                    child: SmallText(
                                                        text: futureDatas[index]
                                                            .desc),
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
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          showDeleteDialog(
                                                              context,
                                                              'other',
                                                              futureDatas[index]
                                                                  .id);
                                                        });
                                                      },
                                                      icon: Icon(
                                                        CupertinoIcons.delete,
                                                        size: 12,
                                                        color: SeyirApp
                                                                    .themeNotifier
                                                                    .value ==
                                                                ThemeMode.light
                                                            ? Colors.red[600]
                                                            : Colors.white,
                                                      )),
                                                ),
                                              ),
                                            ]),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SmallText(
                                                  text: futureDatas[index]
                                                      .addressName),
                                              SizedBox(
                                                  height:
                                                      height(context) / 84.4),
                                              SmallText(
                                                  text: futureDatas[index]
                                                      .created
                                                      .toString()
                                                      .substring(0, 10)),
                                            ],
                                          ),
                                          futureDatas[index].checked == true
                                              ? const SmallText(text: '')
                                              : const Text('Kabul edilmedik',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Bricolage',
                                                    fontSize: 12,
                                                  )),
                                        ]))),
                          ])));
                } else {
                  return const CircularContainerMain();
                }
              })
        ],
      ),
    );
  }
}
