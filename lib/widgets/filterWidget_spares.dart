// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:seyir/pages/lists/main_list.dart';
import 'package:seyir/pages/lists/category_list.dart';
import 'package:seyir/pages/lists/address_list.dart';
import '../component/navbar.dart';
import '../utils/models.dart';

class SparesFilterWidget extends StatefulWidget {
  const SparesFilterWidget({Key? key}) : super(key: key);

  @override
  _SparesFilterWidgetState createState() => _SparesFilterWidgetState();
}

class _SparesFilterWidgetState extends State<SparesFilterWidget>
    with SingleTickerProviderStateMixin {
  bool _validate = false;

  String? selectedYear;
  String? selectedCondition;

  final TextEditingController minPriceCtr = TextEditingController();
  final TextEditingController maxPriceCtr = TextEditingController();

  List<AddressPage> addresses = [];
  List<SaylananSalgy> selectedSubaddresses = [];

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      InkWell(
                        onTap: () async {
                          final result =
                              await Navigator.push<List<SaylananCategory>>(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => CategoryListPage(
                                        queryName: 'atiyaclik-saylar',
                                      ),
                                ),
                              );
                          if (result != null)
                            setState(() => selectedSubcategories = result);
                        },
                        child: _selectBox(
                          context,
                          'Kategoriýany saýla',
                          Icons.category_outlined,
                        ),
                      ),
                      if (selectedSubcategories.isNotEmpty)
                        _buildChipGroup(selectedSubcategories, (id) {
                          setState(
                            () => selectedSubcategories.removeWhere(
                              (item) => item.id == id,
                            ),
                          );
                        }),

                      const SizedBox(height: 16),

                      /// --- SALGY ---
                      InkWell(
                        onTap: () async {
                          final result =
                              await Navigator.push<List<SaylananSalgy>>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MainAddressPage(),
                                ),
                              );
                          if (result != null)
                            setState(() => selectedSubaddresses = result);
                        },
                        child: _selectBox(
                          context,
                          'Salgyny saýla',
                          Icons.location_on_outlined,
                        ),
                      ),
                      if (selectedSubaddresses.isNotEmpty)
                        _buildChipGroup(selectedSubaddresses, (id) {
                          setState(
                            () => selectedSubaddresses.removeWhere(
                              (item) => item.id == id,
                            ),
                          );
                        }),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              // Dropdown açylanda menýunyň dizaýny
                              dropdownColor:
                                  Theme.of(context)
                                      .colorScheme
                                      .primaryContainer, // Açylýan listiň fon reňki
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ), // Ikon üýtgetmek
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 12,
                                fontFamily: 'Bricolage',
                              ),

                              decoration: InputDecoration(
                                labelText: 'Ýagdaýy',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),

                                // Gyranyň tegelek we reňkli bolmagy
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width: 2,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    width: 1,
                                  ),
                                ),
                              ),

                              value: selectedCondition,
                              // Menýunyň içindäki elementleriň dizaýny
                              items: [
                                _buildConditionItem('new', 'Täze'),
                                _buildConditionItem('used', 'Ulanylan'),
                                _buildConditionItem(
                                  'refurbished',
                                  'Dikeldilen',
                                ),
                              ],
                              onChanged:
                                  (val) =>
                                      setState(() => selectedCondition = val),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _priceField(minPriceCtr, 'Min Baha')),
                          const SizedBox(width: 10),
                          Expanded(child: _priceField(maxPriceCtr, 'Max Baha')),
                        ],
                      ),

                      // Gözle düwmesi
                      Container(
                        padding: EdgeInsets.only(top: h / 84.4, bottom: 12),
                        width: w,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _applyFilter,
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

  Widget _priceField(TextEditingController ctr, String label) {
    return TextField(
      controller: ctr,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        contentPadding: const EdgeInsets.only(
          top: 5,
          bottom: 5,
          left: 10,
          right: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 2, color: Colors.white38),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 2, color: Colors.green),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        focusColor: Colors.green[600],
        fillColor: Theme.of(context).colorScheme.primaryContainer,
        errorText: _validate ? "Setiri dolduruň!" : null,
        labelText: label,
        // hintText:_phoneNumber.get(1),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildConditionItem(String value, String text) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: "Bricolage",
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectBox(BuildContext context, String text, IconData icon) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 12),
        ],
      ),
    );
  }

  Widget _buildChipGroup(List items, Function(int) onRemove) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Wrap(
        spacing: 8, // Chip-leriň arasyndaky boşluk
        runSpacing: 8, // Setirleriň arasyndaky boşluk
        children:
            items.map((sub) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Chip(
                  elevation: 0,
                  padding: const EdgeInsets.all(4), // <--- Şuny ulanmaly
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                  label: Text(
                    sub.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  deleteIcon: Icon(
                    Icons.cancel,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.7),
                  ),
                  onDeleted: () => onRemove(sub.id),
                ),
              );
            }).toList(),
      ),
    );
  }

  void _applyFilter() {
    List<String> parts = [];

    if (minPriceCtr.text.isNotEmpty) parts.add('min=${minPriceCtr.text}');
    if (maxPriceCtr.text.isNotEmpty) parts.add('max=${maxPriceCtr.text}');

    // ID-leri dogry formatda ugratmak
    if (selectedSubcategories.isNotEmpty) {
      final catIds = selectedSubcategories.map((e) => e.id).join(',');
      parts.add('category=$catIds');
    }

    if (selectedSubaddresses.isNotEmpty) {
      final addrIds = selectedSubaddresses.map((e) => e.id).join(',');
      parts.add('address=$addrIds');
    }

    String filter = parts.isNotEmpty ? '&${parts.join('&')}' : '';
    log("Generated Filter: $filter");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MainList(
              filter: filter,
              pageName: 'Ätiýaçlyk şaýlar',
              queryName: 'spares',
            ),
      ),
    );
  }
}
