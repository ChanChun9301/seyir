// ignore: file_names
// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:seyir/pages/logist/detail_page_logist.dart';
import '/utils/constants.dart';
import '/utils/getData.dart';
import 'package:flutter/material.dart';
import '/widgets/circulateContainer.dart';
import '/utils/models.dart';
import '../../component/navbar.dart';
import '../../widgets/text.dart';

class LogistFilter extends StatefulWidget {
  final String? name;
  final String? pageName;
  final String? url;
  const LogistFilter(
      {Key? key, required this.url, required this.pageName, required this.name})
      : super(key: key);

  @override
  State<LogistFilter> createState() => _LogistFilter();
}

class _LogistFilter extends State<LogistFilter>
    with SingleTickerProviderStateMixin {
  final control = ScrollController();
  late List<LogistPageModel> futureDatas = [];
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

  @override
  void dispose() {
    control.removeListener(_onScroll);
    control.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!isLoading) {
      isLoading = true;
      final newPageModels =
          await getFilterLogistData(widget.url!, widget.name!);
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
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 10,
              centerTitle: true,
              title: Text(
                widget.name!,
                style: const TextStyle(
                    letterSpacing: 5,
                    fontFamily: "Bricolage",
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    color: Colors.white),
              ),
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.arrow_back_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/logist');
                    },
                  );
                },
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(height(context) / 28.13))),
            )),
        drawer: const NavBar(),
        extendBodyBehindAppBar: true,
        body: Container(
          color: Theme.of(context).colorScheme.background,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
                controller: control,
                physics: const BouncingScrollPhysics(),
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
                                builder: (context) => LogistDetailPage(
                                      id: futureDatas[index].id,
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
                          margin: EdgeInsets.only(
                            top: height(context) / 84.4,
                            left: height(context) / 84.4,
                            right: height(context) / 84.4,
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
                                        topLeft: Radius.circular(
                                            height(context) / 84.4),
                                        bottomLeft: Radius.circular(
                                            height(context) / 84.4)),
                                    color: Colors.white38,
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                            height(context) / 84.4),
                                        bottomLeft: Radius.circular(
                                            height(context) / 84.4),
                                      ),
                                      child: Image.network(
                                        (futureDatas[index].img != '')
                                            ? futureDatas[index].img
                                            : 'assets/no-image.jpg',
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
                                                Text(futureDatas[index].title,
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
                                                            (futureDatas[index]
                                                                        .created
                                                                        .toString()
                                                                        .substring(
                                                                            0,
                                                                            10) !=
                                                                    formattedDate
                                                                        .toString())
                                                                ? futureDatas[
                                                                        index]
                                                                    .lastDate
                                                                    .toString()
                                                                : futureDatas[
                                                                        index]
                                                                    .lastDate
                                                                    .toString(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: (int.parse(futureDatas[index].lastDate.substring(5, 7)) >= month &&
                                                                      int.parse(futureDatas[index].lastDate.substring(
                                                                              8,
                                                                              10)) >=
                                                                          day &&
                                                                      int.parse(futureDatas[index]
                                                                              .lastDate
                                                                              .substring(0,
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
                                                      (futureDatas[index]
                                                                  .isBring ==
                                                              true)
                                                          ? CupertinoIcons
                                                              .arrow_down_square_fill
                                                          : CupertinoIcons
                                                              .arrow_up_square_fill,
                                                      size: 16,
                                                      color: (futureDatas[index]
                                                                  .isBring ==
                                                              true)
                                                          ? Colors.green
                                                          : Colors.blue,
                                                    )
                                                  ],
                                                ),
                                                Text(futureDatas[index].desc,
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
                                                        text: futureDatas[index]
                                                            .nirden
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
                                                            text: futureDatas[
                                                                    index]
                                                                .where
                                                                .toString()),
                                                      ],
                                                    ),
                                                    futureDatas[index]
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
                                                          text:
                                                              futureDatas[index]
                                                                  .categoryName
                                                                  .toString()),
                                                    ),
                                                    SmallText(
                                                        text: (futureDatas[
                                                                        index]
                                                                    .created
                                                                    .toString()
                                                                    .substring(
                                                                        0,
                                                                        10) ==
                                                                formattedDate
                                                                    .toString())
                                                            ? 'Şu gün'
                                                            : futureDatas[index]
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
                  } else {
                    return const CircularContainerMain();
                  }
                }),
          ),
        ));
  }
}
