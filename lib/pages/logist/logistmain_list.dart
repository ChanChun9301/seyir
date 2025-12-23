import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seyir/pages/logist/tabs/tabScreen_one.dart';
import 'package:seyir/pages/logist/tabs/tabScreen_two.dart';
import '/utils/constants.dart';
import '../../component/navbar.dart';
import '/utils/models.dart';

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
            'Logist',
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
          LogistTabOneList(filter: widget.filter),
          LogistTabTwoList(filter: widget.filter),
        ],
      ),
    );
  }
}
