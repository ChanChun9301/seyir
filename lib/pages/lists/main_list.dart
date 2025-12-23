// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:seyir/widgets/circulateContainer.dart';
import 'package:seyir/widgets/filterWidget_car.dart';
import 'package:seyir/widgets/filterWidget_service.dart';
import 'package:seyir/widgets/filterWidget_spares.dart';
import '/component/listAppbar.dart';
import '/utils/constants.dart';
import '../../component/navbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/utils/models.dart';
import '../../widgets/text.dart';
import '../detail_page.dart';
import '../search_delagate.dart';

class MainList extends StatefulWidget {
  final String? pageName;
  final String? queryName;
  String filter = '';
  MainList({
    Key? key,
    required this.pageName,
    required this.queryName,
    required this.filter,
  }) : super(key: key);
  @override
  State<MainList> createState() => _MainListState();
}

class _MainListState extends State<MainList>
    with SingleTickerProviderStateMixin {
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
      final newPageModels = await getData(widget.queryName!, widget.filter);
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
        preferredSize: const Size.fromHeight(40),
        child: ListAppbar(
          titleName: widget.pageName!,
          query: widget.queryName!,
        ),
      ),
      drawer: const NavBar(),
      // extendBodyBehindAppBar: true,
      body: RefreshIndicator(
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
                          delegate: SearchFilter(
                            urlName: widget.queryName!,
                            queries: '',
                          ),
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
                          const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (widget.queryName == 'car') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CarFilterWidget(),
                            ),
                          );
                        } else if (widget.queryName == 'hyzmatlar') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ServiceFilterWidget(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SparesFilterWidget(),
                            ),
                          );
                        }
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
                    return _buildModernListItem(futureDatas[index], context);
                    ;
                  } else {
                    return const CircularContainerMain();
                  }
                },
              ),
            ],
          ),
        ),
      ),
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
                (_) => DetailPage(
                  id: item.id,
                  query: widget.queryName!,
                  title: item.title,
                ),
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
                  (item.img != '') ? item.img : 'assets/no-image.jpg',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
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
                      SmallText(text: item.addressName ?? ""),

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

  Future<List<PageModel>> getData(String urlName, String filter) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$urlName/?checked=True&page=$page$filter'),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List results = data['results'];
      return results.map((e) => PageModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
