import 'package:seyir/pages/create/create_spare.dart';
import 'package:seyir/pages/create/update_spare.dart';
import 'package:seyir/api/fetch_spare.dart';
import 'package:seyir/pages/spare/detail_spare_page.dart';
import '/main.dart';
import '/utils/constants.dart';
import '../../utils/dialogs.dart';
import '../../widgets/circulateContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/utils/models.dart';
import '../text.dart';

class AddedSparesWidget extends StatefulWidget {
  final String token;
  const AddedSparesWidget({Key? key, required this.token}) : super(key: key);
  @override
  State<AddedSparesWidget> createState() => _AddedSparesWidgetState();
}

class _AddedSparesWidgetState extends State<AddedSparesWidget>
    with SingleTickerProviderStateMixin {
  late List<SparePageModel> futureDatas = [];

  final control = ScrollController();

  int page = 1;
  bool hasMore = true;
  bool isLoading = false;
  bool _isRefreshing = false;

  int day = now.day;
  int month = now.month;
  int year = now.year;

  @override
  void initState() {
    super.initState();
    control.addListener(_onScroll);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!isLoading) {
      isLoading = true;
      final newPageModels = await getAddedData(widget.token, page);
      if (mounted) {
        setState(() {
          futureDatas.addAll(newPageModels);
        });
      }
      page++;
      isLoading = false;
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

  void _onScroll() {
    if (control.position.pixels == control.position.maxScrollExtent) {
      _loadData();
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
            padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Awto şaýlary',
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
                          MaterialPageRoute(
                            builder: (context) => const CreateSpare(),
                          ),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(3),
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 16),
                ),
              ],
            ),
          ),
          ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: futureDatas.length,
            itemBuilder: (context, index) {
              if (index < futureDatas.length) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SpareDetailPage(
                              id: futureDatas[index].id,
                              title: futureDatas[index].title,
                            ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(99, 99, 99, 0.18),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                      color: Theme.of(context).colorScheme.primaryContainer,
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
                          tag: 'spares-${futureDatas[index].id}',
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          child: BigText(
                                            text: futureDatas[index].title,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 250,
                                          child: SmallText(
                                            text: removeHtmlTags(
                                              futureDatas[index].desc,
                                            ),
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              showDeleteDialog(
                                                context,
                                                'spares',
                                                futureDatas[index].id,
                                              );
                                            });
                                          },
                                          icon: Icon(
                                            CupertinoIcons.delete,
                                            size: 12,
                                            color:
                                                SeyirApp.themeNotifier.value ==
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
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => UpdateSpare(
                                                        id: int.parse(
                                                          futureDatas[index].id,
                                                        ),
                                                        isEditing: true,
                                                      ),
                                                ),
                                              );
                                            });
                                          },
                                          icon: Icon(
                                            CupertinoIcons.pencil,
                                            size: 14,
                                            color:
                                                SeyirApp.themeNotifier.value ==
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
                                  SmallText(
                                    text: futureDatas[index].addressName,
                                  ),
                                  SizedBox(height: height(context) / 84.4),
                                  SmallText(
                                    text: futureDatas[index].created
                                        .toString()
                                        .substring(0, 10),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const CircularContainerMain();
              }
            },
          ),
        ],
      ),
    );
  }
}
