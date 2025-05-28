import 'package:hive_flutter/hive_flutter.dart';
import 'package:seyir/widgets/add_lists/added_car.dart';
import 'package:seyir/widgets/add_lists/added_other.dart';
import 'package:seyir/widgets/add_lists/added_elin.dart';
import 'package:seyir/widgets/add_lists/added_service.dart';
import 'package:flutter/material.dart';
import '../../pages/logist/added_logist.dart';
import '../../component/navbar.dart';
import '../../utils/models.dart';

class AddedList extends StatefulWidget {
  const AddedList({Key? key}) : super(key: key);
  @override
  State<AddedList> createState() => _AddedListState();
}

class _AddedListState extends State<AddedList>
    with SingleTickerProviderStateMixin {
  late Future<List<PageModel>> futureDatas;
  final control = ScrollController();

  final _appToken = Hive.box('apptoken');
  var token = '';
  @override
  void initState() {
    super.initState();
    setState(() {
      token = _appToken.get('token') ?? '';
    });
  }

  int current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            notificationPredicate: (ScrollNotification notification) {
              return notification.depth == 1;
            },
            centerTitle: true,
            scrolledUnderElevation: 4.0,
            title: const Text(
              'Goşulanlar',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                  fontFamily: "Bricolage",
                  fontSize: 20,
                  color: Colors.white),
            ),
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
      extendBodyBehindAppBar: true,
      drawer: const NavBar(),
      body: PageView(children: [
        AddedLogist(token: token),
        AddedCarWidget(token: token),
        AddedServiceWidget(token: token),
        AddedElinWidget(token: token),
        AddedOtherWidget(token: token),
      ]),
    );
  }
}
