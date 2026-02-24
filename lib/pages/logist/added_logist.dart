// import 'dart:developer';
import './create/update.dart';
import 'package:seyir/pages/logist/detail_page_logist.dart';
import 'package:seyir/widgets/listDescText.dart';
import 'package:seyir/api/fetch_logist.dart';
import '/main.dart';
import '/utils/constants.dart';
import 'create/create_logist.dart';
import '../../utils/dialogs.dart';
import '../../widgets/circulate_Container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/utils/models.dart';
import '../../widgets/text.dart';

class AddedLogist extends StatefulWidget {
  final String token;
  const AddedLogist({super.key, required this.token});
  @override
  State<AddedLogist> createState() => _AddedLogistState();
}

class _AddedLogistState extends State<AddedLogist>
    with SingleTickerProviderStateMixin {
  late List<LogistPageModel> futureDatas = [];
  final control = ScrollController();

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

  Future<void> _loadData() async {
    if (!isLoading) {
      isLoading = true;
      final newPageModels = await getAddedLogistData(widget.token, page);
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
  void dispose() {
    control.removeListener(_onScroll);
    control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        controller: control,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Logistika',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Bricolage',
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    (SeyirApp.tokenNotifier.value == false)
                        ? showAlertDialog(context)
                        : Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreateLog()),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(3),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          futureDatas.isNotEmpty
              ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                    isLoading ? futureDatas.length + 1 : futureDatas.length,
                itemBuilder: (context, index) {
                  int lastday = int.parse(
                    futureDatas[index].lastDate.substring(8, 10),
                  );
                  int lastmonth = int.parse(
                    futureDatas[index].lastDate.substring(5, 7),
                  );
                  int lastyear = int.parse(
                    futureDatas[index].lastDate.substring(0, 4),
                  );

                  if (index < futureDatas.length) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LogistDetailPage(
                                  id: futureDatas[index].id,
                                  title: futureDatas[index].title,
                                ),
                          ),
                        );
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(99, 99, 99, 0.18),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        margin: EdgeInsets.symmetric(
                          horizontal: height(context) / 84.4,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'logist-two-${futureDatas[index].id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  futureDatas[index].img.isNotEmpty
                                      ? futureDatas[index].img
                                      : '',
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    // height: 33,
                                    width: double.infinity,
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: width(context) / 2,
                                              child: BigText(
                                                text: futureDatas[index].title,
                                              ),
                                            ),
                                            SmallText(
                                              text:
                                                  (futureDatas[index].created
                                                              .toString()
                                                              .substring(
                                                                0,
                                                                10,
                                                              ) ==
                                                          formattedDate)
                                                      ? 'Şu gün'
                                                      : futureDatas[index]
                                                          .created
                                                          .toString()
                                                          .substring(0, 10),
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
                                                  BorderRadius.circular(50),
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  showDeleteDialog(
                                                    context,
                                                    'logist',
                                                    futureDatas[index].id,
                                                  );
                                                });
                                              },
                                              icon: Icon(
                                                CupertinoIcons.delete,
                                                size: 14,
                                                color:
                                                    SeyirApp
                                                                .themeNotifier
                                                                .value ==
                                                            ThemeMode.light
                                                        ? Colors.red[600]
                                                        : Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 35,
                                          top: 0,
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              UpdateLogist(id: int.parse(futureDatas[index].id),isEditing: true,),
                                                    ),
                                                  );
                                                });
                                              },
                                              icon: Icon(
                                                CupertinoIcons.pencil,
                                                size: 14,
                                                color:
                                                    SeyirApp
                                                                .themeNotifier
                                                                .value ==
                                                            ThemeMode.light
                                                        ? Colors.green[600]
                                                        : Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Ahyrky sene:',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Bricolage',
                                              fontSize: 10,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            (futureDatas[index].created
                                                        .toString()
                                                        .substring(0, 10) !=
                                                    formattedDate.toString())
                                                ? futureDatas[index].lastDate
                                                    .toString()
                                                : futureDatas[index].lastDate
                                                    .toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  (lastmonth >= month &&
                                                          lastday >= day &&
                                                          lastyear >= year)
                                                      ? Theme.of(
                                                        context,
                                                      ).colorScheme.secondary
                                                      : Colors.red,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Bricolage',
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            (futureDatas[index].isBring == true)
                                                ? 'Getirmeli'
                                                : 'Alyp gitmeli',
                                            style: TextStyle(
                                              color:
                                                  (futureDatas[index].isBring ==
                                                          true)
                                                      ? (SeyirApp
                                                                  .themeNotifier
                                                                  .value ==
                                                              ThemeMode.light
                                                          ? Colors
                                                              .green
                                                              .shade500
                                                          : Colors
                                                              .grey
                                                              .shade200)
                                                      : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Bricolage',
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Icon(
                                            (futureDatas[index].isBring == true)
                                                ? CupertinoIcons
                                                    .arrow_down_square_fill
                                                : CupertinoIcons
                                                    .arrow_up_square_fill,
                                            size: 18,
                                            color:
                                                (futureDatas[index].isBring ==
                                                        true)
                                                    ? Colors.green
                                                    : Colors.blue,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: DescTextWidget(
                                          desc: futureDatas[index].desc,
                                        ),
                                      ),
                                      Text(
                                        (futureDatas[index].isClient == true)
                                            ? 'Müşderi'
                                            : 'Ulag',
                                        style: TextStyle(
                                          color: Colors.green.shade500,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Bricolage',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),

                                  futureDatas[index].checked == true
                                      ? const SmallText(text: '')
                                      : const Text(
                                        'Kabul edilmedik',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Bricolage',
                                          fontSize: 12,
                                        ),
                                      ),

                                  const SizedBox(height: 2),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: CircularContainerMain(),
                    );
                  }
                },
              )
              : Center(
                heightFactor: height(context) / 56.23,
                child: Text(
                  'Haryt tapylmady!',
                  style: TextStyle(
                    fontFamily: 'Bricolage',
                    letterSpacing: 3,
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  bool _isDateValid(String date) {
    final d = DateTime.parse(date);
    return d.isAfter(DateTime.now());
  }

  Widget buildLogistModernItemCard({
    required BuildContext context,
    required LogistPageModel item,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LogistDetailPage(id: item.id, title: item.title),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: height(context) / 84.4,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(99, 99, 99, 0.18),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// IMAGE
            Hero(
              tag: 'logist-two-${item.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.img.isNotEmpty ? item.img : 'assets/no-image.jpg',
                  width: 90,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// CONTENT
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
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Bricolage',
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// DEADLINE + TYPE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Ahyrky sene:',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Bricolage',
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.lastDate,
                            style: TextStyle(
                              color:
                                  _isDateValid(item.lastDate)
                                      ? theme.colorScheme.secondary
                                      : Colors.red,
                              fontFamily: 'Bricolage',
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            item.isBring ? 'Getirmeli' : 'Alyp gitmeli',
                            style: TextStyle(
                              color:
                                  item.isBring
                                      ? (SeyirApp.themeNotifier.value ==
                                              ThemeMode.light
                                          ? Colors.green.shade500
                                          : Colors.grey.shade200)
                                      : Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Bricolage',
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            item.isBring
                                ? CupertinoIcons.arrow_down_square_fill
                                : CupertinoIcons.arrow_up_square_fill,
                            size: 18,
                            color: item.isBring ? Colors.green : Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// DESCRIPTION
                  Text(
                    removeHtmlTags(item.desc),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.onSecondary,
                      fontFamily: 'Bricolage',
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// FROM
                  Row(
                    children: [
                      Text(
                        'Nirden:',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Bricolage',
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: SmallText(text: item.nirden)),
                    ],
                  ),

                  /// TO + STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Nirä:',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Bricolage',
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 120,
                            child: SmallText(text: item.where),
                          ),
                        ],
                      ),
                      item.checked
                          ? const SizedBox()
                          : const Text(
                            'Kabul edilmedik',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontFamily: 'Bricolage',
                              fontSize: 10,
                            ),
                          ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// CATEGORY + DATE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: SmallText(text: item.categoryName),
                      ),
                      SmallText(
                        text:
                            item.created.toString().substring(0, 10) ==
                                    formattedDate
                                ? 'Şu gün'
                                : item.created.toString().substring(0, 10),
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
