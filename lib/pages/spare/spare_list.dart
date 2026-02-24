// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:seyir/widgets/circulateContainer.dart';
import 'package:seyir/api/fetch_spare.dart';
import 'package:seyir/widgets/filterWidget_car.dart';
import 'package:seyir/widgets/filterWidget_service.dart';
import 'package:seyir/widgets/filterWidget_spares.dart';
import '/utils/constants.dart';
import '../../component/navbar.dart';
import '/utils/models.dart';
import '../../widgets/text.dart';
import './detail_spare_page.dart';
import '../search_delagate.dart';

// ignore: must_be_immutable
class SpareMainList extends StatefulWidget {
  String filter = '';
  SpareMainList({super.key, required this.filter});
  @override
  State<SpareMainList> createState() => _SpareMainListState();
}

class _SpareMainListState extends State<SpareMainList>
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
      final newPageModels = await getData(page, widget.filter);
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
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 10,
          centerTitle: true,
          title: Text(
            'Awto şaýlary',
            style: const TextStyle(
              // fontStyle: FontStyle.italic,
              letterSpacing: 2,
              fontFamily: "Bricolage",
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  // Eger filter boş däl bolsa, doldurylan ikony görkezýäris
                  icon: Icon(
                    widget.filter != "" && widget.filter != null
                        ? Icons
                            .filter_alt // Doldurylan ikon
                        : Icons.filter_alt_outlined, // Diňe çyzykly ikon
                  ),
                  tooltip: 'Gözle',
                  color: Colors.white,
                  iconSize: 20, // 16 azajyk kiçi görner, 20 has oňat
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SparesFilterWidget(),
                      ),
                    );
                  },
                ),
                // Eger filter bar bolsa, gyzyl ýa-da sary nokatjygy görkezýäris
                if (widget.filter != "" && widget.filter != null)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color:
                            Colors
                                .orange, // Seniň dizaýnyňa görä reňkini üýtgedip bilersiň
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.filter != '')
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                ), // "clear" ýerine has döwrebap ikon
                tooltip: 'Filteri arassala',
                color: Colors.white70, // Biraz dury bolsa has gelşikli durar
                onPressed: () {
                  setState(() {
                    // 1. Filter parametrini boşat
                    widget.filter = '';

                    // 2. Sahypany başa döndür
                    page = 1;

                    // 3. Köne maglumat listini arassala
                    futureDatas.clear();

                    // 4. Täze maglumatlary çekmek üçin baydagy (flag) nolla
                    hasMore = true;
                  });

                  // 5. API-dan filtersiz maglumatlary gaýtadan çek
                  _loadData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Filter arassalandy"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),

            IconButton(
              icon: const Icon(Icons.search_outlined),
              tooltip: 'Gözle',
              color: Colors.white,
              iconSize: 20,
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SearchFilter(urlName: 'spares', queries: 'spares'),
                );
              },
            ),
          ],
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons.sort_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      drawer: const NavBar(),
      // extendBodyBehindAppBar: true,
      body: RefreshIndicator(
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
                    return _buildModernListItem(futureDatas[index], context);
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
            builder: (_) => SpareDetailPage(id: item.id, title: item.title),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(8),
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
          ],
        ),
      ),
    );
  }
}
