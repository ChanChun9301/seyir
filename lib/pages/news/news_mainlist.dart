// ignore_for_file: file_names
import 'package:flutter/material.dart';
import '/utils/constants.dart';
import '../../component/navbar.dart';
import 'news_detailpage.dart';
import 'news_searchdelagate.dart';
import '/utils/getData.dart';
import '/utils/models.dart';
import '../../widgets/text.dart';

class NewsMainList extends StatefulWidget {
  const NewsMainList({Key? key}) : super(key: key);
  @override
  State<NewsMainList> createState() => _NewsMainListState();
}

class _NewsMainListState extends State<NewsMainList>
    with SingleTickerProviderStateMixin {
  late List<NewsPage> futureDatas = [];
  final control = ScrollController();

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
      final newPageModels = await getDataNews();
      setState(() {
        futureDatas.addAll(newPageModels);
      });
      page++;
      isLoading = false;
    }
  }

  void _onScroll() {
    if (control.position.pixels >= control.position.maxScrollExtent) {
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
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              // elevation: 10,
              centerTitle: true,
              title: const Text(
                'Habarlar',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2,
                    fontFamily: "Bricolage",
                    fontSize: 20,
                    color: Colors.white),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.search_outlined),
                  color: Colors.white,
                  iconSize: 20,
                  onPressed: () {
                    showSearch(context: context, delegate: NewsSearchFilter());
                  },
                ),
              ],
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.sort_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30))),
            )),
        backgroundColor: Theme.of(context).colorScheme.background,
        extendBodyBehindAppBar: true,
        drawer: const NavBar(),
        body: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: ListView.builder(
                  controller: control,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: futureDatas.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewsDetailPage(
                                        title: futureDatas[index].title,
                                        id: futureDatas[index].id,
                                      )));
                        },
                        child: Container(
                            margin: EdgeInsets.only(
                                left: h / 84.4, right: h / 84.4, top: h / 84.4),
                            width: double.infinity,
                            height: 90,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(h / 84.4)),
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            child: Row(children: [
                              Container(
                                width: 150,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(h / 84.4),
                                    bottomLeft: Radius.circular(h / 84.4),
                                  ),
                                  color: Colors.white38,
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(h / 84.4),
                                      bottomLeft: Radius.circular(h / 84.4),
                                    ),
                                    child: Image.network(
                                      futureDatas[index].img,
                                      fit: BoxFit.fill,
                                    )),
                              ),
                              Expanded(
                                child: SizedBox(
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: height(context) / 84.4,
                                            right: height(context) / 84.4),
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
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Bricolage',
                                                    fontSize: 12,
                                                  )),
                                              Text(futureDatas[index].desc,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSecondary,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Bricolage',
                                                    fontSize: 10,
                                                  )),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SmallText(
                                                      text: (futureDatas[index]
                                                                  .created
                                                                  .toString()
                                                                  .substring(
                                                                      0, 10) ==
                                                              formattedDate)
                                                          ? 'Şu gün'
                                                          : futureDatas[index]
                                                              .created
                                                              .toString()
                                                              .substring(
                                                                  0, 10)),
                                                  SmallText(
                                                      text: futureDatas[index]
                                                          .author)
                                                ],
                                              ),
                                            ]))),
                              ),
                            ])));
                  }),
            )));
  }
}
