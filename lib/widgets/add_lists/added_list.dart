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

class _AddedListState extends State<AddedList> {
  final _appToken = Hive.box('apptoken');

  late Future<String> futureToken;

  @override
  void initState() {
    super.initState();
    futureToken = _loadToken();
  }

  Future<String> _loadToken() async {
    // Имитация асинхронной загрузки, можно убрать await если не нужно
    await Future.delayed(Duration(milliseconds: 100));
    final token = _appToken.get('phone')?.toString() ?? '';
    // Возвращаем безопасный вариант
    return token.length > 3 ? token : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          scrolledUnderElevation: 4.0,
          title: const Text(
            'Goşulanlar',
            style: TextStyle(
              fontStyle: FontStyle.italic,
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
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      drawer: const NavBar(),
      body: FutureBuilder<String>(
        future: futureToken,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Пока загружаем токен, можно показать спиннер
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Если произошла ошибка при загрузке
            return Center(child: Text('Ошибка загрузки токена'));
          }

          final safeToken = snapshot.data ?? '';

          return PageView(
            children: [
              AddedLogist(token: safeToken),
              AddedCarWidget(token: safeToken),
              AddedServiceWidget(token: safeToken),
              AddedElinWidget(token: safeToken),
              AddedOtherWidget(token: safeToken),
            ],
          );
        },
      ),
    );
  }
}
