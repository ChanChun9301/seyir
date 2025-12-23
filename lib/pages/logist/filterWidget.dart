// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'package:flutter/material.dart';
import 'package:seyir/pages/logist/create/logistaddress.dart';
import 'package:seyir/pages/logist/create/logistcategory.dart';
import 'package:seyir/pages/logist/logistmain_list.dart';
import '../../widgets/fields/text_field_row.dart';
import '../../component/navbar.dart';
import '../../utils/models.dart';
import '../../utils/constants.dart';
import '../../api/fetch_logist.dart';

class LogistFilterWidget extends StatefulWidget {
  final String? client;
  final List categories;

  const LogistFilterWidget({
    super.key,
    required this.categories,
    required this.client,
  });

  @override
  _LogistFilterWidgetState createState() => _LogistFilterWidgetState();
}

class _LogistFilterWidgetState extends State<LogistFilterWidget> {
  final bool _validate = false;
  final String text = 'Setir ýalňyş';

  bool selectedGet = false;
  bool selectedBring = false;

  /// ✅ SELECTED LISTS
  List<SaylananSalgy> selectedSubaddresses = [];
  List<SaylananCategory> selectedSubcategories = [];

  TextEditingController whereCtr = TextEditingController();
  TextEditingController nirdenCtr = TextEditingController();
  TextEditingController priceFromCtr = TextEditingController();
  TextEditingController priceToCtr = TextEditingController();
  TextEditingController minPrice = TextEditingController();
  TextEditingController maxPrice = TextEditingController();

  bool showSpinner = false;
  Future<List<AddressPage>>? _addressesFuture;

  @override
  void initState() {
    super.initState();
    _addressesFuture = fetchAddress();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          title: const Text(
            'Filter gözlegi',
            style: TextStyle(
              fontFamily: "Bricolage",
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.sort_outlined, size: 16),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      body:
          showSpinner
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<AddressPage>>(
                future: _addressesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: h / 56.27),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: h / 84.4),

                        /// ================= ADDRESS =================
                        InkWell(
                          onTap: () async {
                            final result =
                                await Navigator.push<List<SaylananSalgy>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LogistAddressPage(),
                                  ),
                                );

                            if (result != null) {
                              setState(() {
                                selectedSubaddresses = result;
                              });
                            }
                          },
                          child: _selectBox(context, 'Salgyny saýla'),
                        ),

                        if (selectedSubaddresses.isNotEmpty) _chipWrapAddress(),

                        SizedBox(height: h / 84.4),

                        /// ================= CATEGORY =================
                        InkWell(
                          onTap: () async {
                            final result =
                                await Navigator.push<List<SaylananCategory>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LogistCategoryPage(),
                                  ),
                                );

                            if (result != null) {
                              setState(() {
                                selectedSubcategories = result;
                              });
                            }
                          },
                          child: _selectBox(context, 'Kategoriýa'),
                        ),

                        if (selectedSubcategories.isNotEmpty)
                          _chipWrapCategory(),

                        SizedBox(height: h / 84.4),

                        /// ================= TEXT FIELDS =================
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldRowCustom(
                                ctr: whereCtr,
                                text: 'Nirä',
                                validate: _validate,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFieldRowCustom(
                                ctr: nirdenCtr,
                                text: 'Nirden',
                                validate: _validate,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: h / 84.4),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 12,
                                  fontFamily: 'Bricolage',
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    borderSide: BorderSide(
                                      width: 2,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    left: 10,
                                    right: 10,
                                  ),
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
                                  focusColor: Colors.green[600],
                                  fillColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  errorText:
                                      _validate ? "Setiri dolduruň!" : null,
                                  labelText: 'Min bahasy',
                                  // hintText:_phoneNumber.get(1),
                                  labelStyle: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                controller: minPrice,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: maxPrice,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 12,
                                  fontFamily: 'Bricolage',
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    borderSide: BorderSide(
                                      width: 2,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    left: 10,
                                    right: 10,
                                  ),
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
                                  focusColor: Colors.green[600],
                                  fillColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  errorText:
                                      _validate ? "Setiri dolduruň!" : null,
                                  labelText: 'Min bahasy',
                                  // hintText:_phoneNumber.get(1),
                                  labelStyle: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: h / 84.4),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSwitch(
                              context: context,
                              value: selectedGet,
                              label: 'Alyp gitmelimi',
                              onChanged: (val) {
                                setState(() {
                                  selectedGet = val;
                                  if (val) selectedBring = false;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildSwitch(
                              context: context,
                              value: selectedBring,
                              label: 'Getirmelimi',
                              onChanged: (val) {
                                setState(() {
                                  selectedBring = val;
                                  if (val) selectedGet = false;
                                });
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: h / 84.4),

                        /// ================= BUTTON =================
                        SizedBox(
                          width: w,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _applyFilter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            child: const Text(
                              'Gözle',
                              style: TextStyle(
                                fontFamily: 'Bricolage',
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  /// ================= HELPERS =================

  Widget _selectBox(BuildContext context, String text) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Bricolage',
            fontSize: 10,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  Widget _chipWrapAddress() {
    return Wrap(
      spacing: 8,
      children:
          selectedSubaddresses.map((sub) {
            return Chip(
              label: Text(sub.name),
              onDeleted: () {
                setState(() {
                  selectedSubaddresses.removeWhere((item) => item.id == sub.id);
                });
              },
            );
          }).toList(),
    );
  }

  Widget _chipWrapCategory() {
    return Wrap(
      spacing: 8,
      children:
          selectedSubcategories.map((sub) {
            return Chip(
              label: Text(sub.name),
              onDeleted: () {
                setState(() {
                  selectedSubcategories.removeWhere(
                    (item) => item.id == sub.id,
                  );
                });
              },
            );
          }).toList(),
    );
  }

  void _applyFilter() {
    List<String> parts = [];

    if (nirdenCtr.text.isNotEmpty) {
      parts.add('nirden=${nirdenCtr.text}');
    }
    if (whereCtr.text.isNotEmpty) {
      parts.add('where=${whereCtr.text}');
    }

    if (minPrice.text.isNotEmpty) {
      parts.add('min=${minPrice.text}');
    }

    if (maxPrice.text.isNotEmpty) {
      parts.add('max=${maxPrice.text}');
    }

    if (selectedSubcategories.isNotEmpty) {
      parts.add('category=${selectedSubcategories.join(',')}');
    }

    /// 🔹 ADDRESS (пример: 1,3)
    if (selectedSubaddresses.isNotEmpty) {
      parts.add('address=${selectedSubaddresses.join(',')}');
    }
    if (selectedBring) {
      parts.add('bring=True');
    } else if (selectedGet) {
      parts.add('bring=False');
    }

    String filter = parts.isNotEmpty ? '&${parts.join('&')}' : '';

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LogistMainList(filter: filter)),
    );
  }

  Widget _buildSwitch({
    required BuildContext context,
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Switch(value: value, onChanged: onChanged),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
        ),
      ],
    );
  }
}
