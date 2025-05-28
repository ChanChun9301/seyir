// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types
import 'package:flutter/material.dart';
import 'package:seyir/pages/logist/logistmain_list.dart';
import '../utils/getData.dart';
import '../widgets/fields/text_field_row.dart';
import '../component/navbar.dart';
import '../utils/models.dart';

class LogistFilterWidget extends StatefulWidget {
  const LogistFilterWidget({
    Key? key,
  }) : super(key: key);

  @override
  _LogistFilterWidgetState createState() => _LogistFilterWidgetState();
}

class _LogistFilterWidgetState extends State<LogistFilterWidget>
    with SingleTickerProviderStateMixin {
  final bool _validate = false;
  bool selectedGet = false;
  bool selectedBring = false;

  TextEditingController whereCtr = TextEditingController();
  TextEditingController nirdenCtr = TextEditingController();
  String filter = '';

  String author = '';

  List<AddressPage> addresses = [];
  AddressPage? selectedAddress;
  List<CategoryPage> categories = [];
  CategoryPage? selectedCategory;

  bool showSpinner = false;
  // final _appToken = Hive.box('apptoken');
  @override
  void initState() {
    super.initState();
    setState(() {
      // author = _appToken.get('token');
    });
    getAddress().then((addressList) {
      setState(() {
        addresses = addressList;
      });
    }).catchError((error) {
      debugPrint(error);
    });
    getDataCategory('logist').then((categoryList) {
      setState(() {
        categories = categoryList;
      });
    }).catchError((error) {
      debugPrint(error);
    });
  }

  int index = 0;
  int count = 5;
  List<Map<String, dynamic>> items = [];
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        drawer: const NavBar(),
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: AppBar(
              title: const Text(
                'Filter gözlegi',
                style: TextStyle(
                    letterSpacing: 2,
                    fontFamily: "Bricolage",
                    fontSize: 16,
                    color: Colors.white),
              ),
              notificationPredicate: (ScrollNotification notification) {
                return notification.depth == 1;
              },
              scrolledUnderElevation: 4.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 10,
              centerTitle: true,
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
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30))),
            )),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: h / 56.27),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: h / 84.4),
              Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    boxShadow: [
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
                  ),
                  child: DropdownButtonFormField<CategoryPage>(
                    dropdownColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 10),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(10),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 2, color: Colors.white38),
                          borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 2, color: Colors.green),
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      focusColor: Colors.white38,
                      fillColor: Theme.of(context).colorScheme.primaryContainer,
                      hintText: "Maglumatlary...",
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    icon: Icon(
                      Icons.expand_circle_down,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    hint: Text('Kategoriýany saýla',
                        style: TextStyle(
                            fontFamily: "Bricolage",
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary)),
                    value: selectedCategory,
                    onChanged: (CategoryPage? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                    items: categories.map<DropdownMenuItem<CategoryPage>>(
                        (CategoryPage category) {
                      return DropdownMenuItem<CategoryPage>(
                        value: category,
                        child: Text(
                          category.title,
                          style: const TextStyle(
                              fontFamily: 'Bricolage', fontSize: 12),
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextFieldRowCustom(
                    ctr: whereCtr,
                    text: 'Nirä',
                    validate: _validate,
                  ),
                  TextFieldRowCustom(
                    ctr: nirdenCtr,
                    text: 'Nirden',
                    validate: _validate,
                  ),
                ],
              ),
              SizedBox(height: h / 84.4),
              SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: 1,
                        child: Switch(
                          value: selectedGet,
                          onChanged: (bool val) {
                            setState(() {
                              if (selectedBring) {
                                selectedGet = false;
                              } else {
                                selectedGet = val;
                              }
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          inactiveThumbColor: Colors.blueGrey.shade600,
                          inactiveTrackColor: Colors.grey.shade400,
                          // splashRadius: 30,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text('Alyp gitmelimi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Bricolage',
                            fontSize: 12,
                          ))
                    ],
                  )),
              SizedBox(height: h / 84.4),
              SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: 1,
                        child: Switch(
                          value: selectedBring,
                          onChanged: (bool val) {
                            setState(() {
                              if (selectedGet) {
                                selectedBring = false;
                              } else {
                                selectedBring = val;
                              }
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          inactiveThumbColor: Colors.blueGrey.shade600,
                          inactiveTrackColor: Colors.grey.shade400,
                          // splashRadius: 30,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text('Getirmelimi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Bricolage',
                            fontSize: 12,
                          ))
                    ],
                  )),
              SizedBox(height: h / 84.4),
              Container(
                padding: EdgeInsets.only(
                  top: h / 84.4,
                  bottom: 12,
                ),
                width: w,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    String text = '';
                    if (nirdenCtr.text.isNotEmpty) {
                      filter += '&nirden=${nirdenCtr.text}';
                    }
                    if (whereCtr.text.isNotEmpty) {
                      filter += '&where=${whereCtr.text}';
                    }
                    if (selectedCategory != null) {
                      filter += '&category=${selectedCategory!.id}';
                    }
                    if (selectedBring) {
                      text = '&bring=True';
                    }
                    if (selectedGet) {
                      text = '&bring=False';
                    }

                    filter += text;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LogistMainList(filter: filter)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  child: const Text(
                    'Gözle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: "Bricolage",
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )));
  }
}
