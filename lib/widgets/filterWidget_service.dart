// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:seyir/pages/lists/main_list.dart';
import 'package:seyir/pages/logist/logistaddress.dart';
import 'package:seyir/pages/logist/logistcategory.dart';
import 'package:seyir/pages/logist/logistmain_list.dart';
import 'package:seyir/utils/constants.dart';
import '../utils/getData.dart';
import '../widgets/fields/text_field_row.dart';
import '../component/navbar.dart';
import '../utils/models.dart';

class ServiceFilterWidget extends StatefulWidget {
  const ServiceFilterWidget({Key? key}) : super(key: key);

  @override
  _ServiceFilterWidgetState createState() => _ServiceFilterWidgetState();
}

class _ServiceFilterWidgetState extends State<ServiceFilterWidget>
    with SingleTickerProviderStateMixin {
  bool _validate = false;
  bool selectedGet = false;
  bool selectedBring = false;

  TextEditingController whereCtr = TextEditingController();
  TextEditingController nirdenCtr = TextEditingController();

  List<AddressPage> addresses = [];
  List<SaylananSalgy> selectedAddresses = [];

  List<CategoryPage> categories = [];
  CategoryPage? selectedCategory;
  List<SaylananCategory> selectedSubcategories = [];

  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
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
                      const SizedBox(height: 10),

                      // Kategoriýa düwmesi
                      SizedBox(
                        width: width(context),
                        child: ElevatedButton(
                          onPressed: () async {
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: Text(
                            'Kategoriýa',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Bricolage',
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Saýlanan kategoriýalar
                      if (selectedSubcategories.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children:
                                  selectedSubcategories.map((e) {
                                    return Chip(
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                      label: Text(
                                        e.name,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          selectedSubcategories.remove(e);
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),

                      // Salgy düwmesi
                      SizedBox(
                        width: width(context),
                        child: ElevatedButton(
                          onPressed: () async {
                            final result =
                                await Navigator.push<List<SaylananSalgy>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LogistAddressPage(),
                                  ),
                                );

                            if (result != null) {
                              setState(() {
                                selectedAddresses = result;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: Text(
                            'Salgy',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Bricolage',
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Saýlanan salgylary
                      if (selectedAddresses.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children:
                                  selectedAddresses.map((e) {
                                    return Chip(
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                      label: Text(
                                        e.name,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          selectedAddresses.remove(e);
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),

                      // TextField lar
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
                      // Gözle düwmesi
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

                            // Saýlanan kategoriýalar bar bolsa
                            if (selectedSubcategories.isNotEmpty) {
                              final categoryIds = selectedSubcategories
                                  .map((e) => e.id)
                                  .join(',');
                              filterParts.add('category=$categoryIds');
                            }

                            // Saýlanan salgylary bar bolsa
                            if (selectedAddresses.isNotEmpty) {
                              final addressIds = selectedAddresses
                                  .map((e) => e.id)
                                  .join(',');
                              filterParts.add('address=$addressIds');
                            }

                            if (selectedBring) {
                              filterParts.add('bring=True');
                            } else if (selectedGet) {
                              filterParts.add('bring=False');
                            }

                            // Eger isleseňiz başlangyç parametrlere goşup bilersiňiz
                            filterParts.add('checked=True');
                            filterParts.add('page=1');

                            String finalFilter = '&${filterParts.join('&')}';
                            log(finalFilter);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MainList(
                                      queryName: 'hyzmatlar',
                                      pageName: 'Hyzmatlar',
                                      filter: finalFilter,
                                    ),
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
