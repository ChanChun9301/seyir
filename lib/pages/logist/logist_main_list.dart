import 'package:flutter/material.dart';
import 'package:seyir/pages/logist/tabs/tabScreen_one.dart';
import 'package:seyir/pages/logist/tabs/tabScreen_two.dart';
import '/utils/constants.dart';
import '../../component/navbar.dart';
import '/utils/models.dart';
import 'package:seyir/pages/logist/logist_search_delagate.dart';
import 'package:seyir/pages/logist/filterWidget.dart';

// ignore: must_be_immutable
class LogistMainList extends StatefulWidget {
  String filter = '';

  LogistMainList({super.key, required this.filter});
  @override
  State<LogistMainList> createState() => _LogistMainListState();
}

class _LogistMainListState extends State<LogistMainList>
    with SingleTickerProviderStateMixin {
  late List<LogistPageModel> futureDatas = [];
  final control = ScrollController();
  late TabController _tabController;

  int day = now.day;
  int month = now.month;
  int year = now.year;

  int updateCounter = 0;

  int page = 1;
  bool hasMore = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 10,
          centerTitle: true,
          title: Text(
            'Logistika',
            style: const TextStyle(
              // fontStyle: FontStyle.italic,
              letterSpacing: 2,
              fontFamily: "Bricolage",
              fontSize: 16,
              color: Colors.white,
            ),
          ),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const LogistFilterWidget(categories: []),
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
                    // 1. Filteri nollamak (Eger bu String bolsa)
                    // Bellik: Widget-iň içindäki däl, State-iň içindäki filteri üýtgetmeli
                    widget.filter = '';
                    updateCounter++;

                    // 2. Täze maglumatlary API-dan gaýtadan çekmek üçin
                    // _futureData = fetchLogist(filter: '');
                  });

                  // Ulanyja filteriň pozulandygyny bildirmek üçin kiçijik habar (optional)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Filter arassalandy",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Bricolage",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                showSearch(context: context, delegate: LogistSearchFilter());
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white, // Saýlanan tab text reňki
            unselectedLabelColor:
                Colors.grey[300], // Saýlanmadyk tab text reňki
            indicatorColor: Colors.orange, // Aşaky çyzyk reňki
            indicatorWeight: 3, // Çyzyk galyňlygy
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [Tab(text: 'Ulaglar'), Tab(text: 'Müşderiler')],
          ),
        ),
      ),
      // extendBodyBehindAppBar: true,
      drawer: const NavBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: TabBarView(
        controller: _tabController,

        children: [
          LogistTabOneList(
            key: ValueKey('tab1_$updateCounter'),
            filter: widget.filter,
          ),
          LogistTabTwoList(
            key: ValueKey('tab2_$updateCounter'),
            filter: widget.filter,
          ),
        ],
      ),
    );
  }
}
