import '/utils/constants.dart';
import '/utils/getData.dart';
import 'package:flutter/material.dart';
import '/widgets/circulateContainer.dart';
import '/utils/models.dart';
import '../../component/navbar.dart';
import '../../widgets/text.dart';
import '../detail_page.dart';

class Filter extends StatefulWidget {
  final String? name;
  final String? pageName;
  final String? url;
  const Filter(
      {Key? key, required this.url, required this.pageName, required this.name})
      : super(key: key);

  @override
  State<Filter> createState() => _CarFilter();
}

class _CarFilter extends State<Filter> with SingleTickerProviderStateMixin {
  late List<PageModel> futureDatas = [];
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
      final newPageModels =
          await getFilterData(widget.pageName!, widget.url!, widget.name!);
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
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2,
                    fontFamily: "Bricolage",
                    fontSize: 20,
                    color: Colors.white),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_outward_outlined),
                  color: Colors.white,
                  iconSize: 20,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.sort_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(height(context) / 28.13))),
            )),
        extendBodyBehindAppBar: true,
        drawer: const NavBar(),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
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
                                builder: (context) => DetailPage(
                                      id: futureDatas[index].id,
                                      query: widget.pageName!,
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
                          height: 90,
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
                                              left: 10, right: 10, bottom: 10),
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
                                                Text(futureDatas[index].desc,
                                                    maxLines: 2,
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SmallText(
                                                        text: futureDatas[index]
                                                            .addressName
                                                            .toString()),
                                                    SmallText(
                                                        text: futureDatas[index]
                                                            .categoryName
                                                            .toString()),
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
