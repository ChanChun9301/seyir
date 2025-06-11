// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'package:flutter/material.dart';
import 'package:seyir/pages/logist/logistaddress.dart';
import 'package:seyir/pages/logist/logistcategory.dart';
import 'package:seyir/pages/logist/logistmain_list.dart';
import 'package:seyir/utils/constants.dart';
import '../utils/getData.dart';
import '../widgets/fields/text_field_row.dart';
import '../component/navbar.dart';
import '../utils/models.dart';

class LogistFilterWidget extends StatefulWidget {
  const LogistFilterWidget({Key? key}) : super(key: key);

  @override
  _LogistFilterWidgetState createState() => _LogistFilterWidgetState();
}

class _LogistFilterWidgetState extends State<LogistFilterWidget>
    with SingleTickerProviderStateMixin {
  bool _validate = false;
  bool selectedGet = false;
  bool selectedBring = false;

  TextEditingController whereCtr = TextEditingController();
  TextEditingController nirdenCtr = TextEditingController();

  List<AddressPage> addresses = [];
  AddressPage? selectedAddress;

  List<CategoryPage> categories = [];
  CategoryPage? selectedCategory;

  bool showSpinner = false;

  @override
  void initState() {
    super.initState();

    getAddress()
        .then((addressList) {
          setState(() {
            addresses = addressList;
          });
        })
        .catchError((error) {
          debugPrint(error);
        });

    getDataCategory('logist')
        .then((categoryList) {
          setState(() {
            categories = categoryList;
          });
        })
        .catchError((error) {
          debugPrint(error);
        });
  }

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
              color: Colors.white,
            ),
          ),
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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body:
          showSpinner
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<CategoryPage>(
                          dropdownColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 10,
                          ),
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.all(10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 2,
                                color: Colors.white38,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 2,
                                color: Colors.green,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).colorScheme.primaryContainer,
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
                          hint: Text(
                            'Kategoriýany saýla',
                            style: TextStyle(
                              fontFamily: "Bricolage",
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          value: selectedCategory,
                          onChanged: (CategoryPage? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                          items:
                              categories.map((CategoryPage category) {
                                return DropdownMenuItem<CategoryPage>(
                                  value: category,
                                  child: Text(
                                    category.title,
                                    style: const TextStyle(
                                      fontFamily: 'Bricolage',
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push<List<SaylananCategory>>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LogistCategoryPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                top: 8,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(height(context) / 84.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(99, 99, 99, 0.2),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              width: w / 2.2,
                              height: 30,
                              child: Text(
                                'Kategoriýa',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 10,
                                  fontFamily: 'Bricolage',
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push<List<SaylananSalgy>>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LogistAddressPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                top: 8,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(height(context) / 84.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(99, 99, 99, 0.2),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              width: w / 2.2,
                              height: 30,
                              child: Text(
                                'Salgy',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 10,
                                  fontFamily: 'Bricolage',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                      _buildSwitch(
                        context: context,
                        value: selectedGet,
                        label: 'Alyp gitmelimi',
                        onChanged: (bool val) {
                          setState(() {
                            selectedGet = val;
                            if (val) selectedBring = false;
                          });
                        },
                      ),
                      SizedBox(height: h / 84.4),
                      _buildSwitch(
                        context: context,
                        value: selectedBring,
                        label: 'Getirmelimi',
                        onChanged: (bool val) {
                          setState(() {
                            selectedBring = val;
                            if (val) selectedGet = false;
                          });
                        },
                      ),
                      SizedBox(height: h / 84.4),
                      Container(
                        padding: EdgeInsets.only(top: h / 84.4, bottom: 12),
                        width: w,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            List<String> filterParts = [];

                            if (nirdenCtr.text.isNotEmpty) {
                              filterParts.add('nirden=${nirdenCtr.text}');
                            }
                            if (whereCtr.text.isNotEmpty) {
                              filterParts.add('where=${whereCtr.text}');
                            }
                            if (selectedCategory != null) {
                              filterParts.add(
                                'category=${selectedCategory!.id}',
                              );
                            }
                            if (selectedBring) {
                              filterParts.add('bring=True');
                            } else if (selectedGet) {
                              filterParts.add('bring=False');
                            }

                            String finalFilter =
                                filterParts.isNotEmpty
                                    ? '&${filterParts.join('&')}'
                                    : '';

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        LogistMainList(filter: finalFilter),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
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
                ),
              ),
    );
  }

  Widget _buildSwitch({
    required BuildContext context,
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveThumbColor: Colors.blueGrey.shade600,
              inactiveTrackColor: Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.w400,
              fontFamily: 'Bricolage',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
