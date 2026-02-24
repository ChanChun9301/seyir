// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'dart:developer';
import 'package:seyir/pages/lists/address_list.dart';
import 'package:flutter/material.dart';
import 'package:seyir/pages/lists/main_list.dart';
import 'package:seyir/pages/lists/category_list.dart';
import '../component/navbar.dart';
import '../utils/models.dart';

class ServiceFilterWidget extends StatefulWidget {
  const ServiceFilterWidget({Key? key}) : super(key: key);

  @override
  _ServiceFilterWidgetState createState() => _ServiceFilterWidgetState();
}

class _ServiceFilterWidgetState extends State<ServiceFilterWidget>
    with SingleTickerProviderStateMixin {
  final bool _validate = false;
  bool selectedGet = false;
  bool selectedBring = false;

  TextEditingController minPriceCtr = TextEditingController();
  TextEditingController maxPriceCtr = TextEditingController();

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

                      // Kategoriýa düwmesi
                      InkWell(
                        onTap: () async {
                          final result =
                              await Navigator.push<List<SaylananCategory>>(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => CategoryListPage(
                                        queryName: 'hyzmatlar',
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

                      // Saýlanan kategoriýalar
                      if (selectedSubcategories.isNotEmpty)
                        _buildChipGroup(selectedSubcategories, (id) {
                          setState(
                            () => selectedSubcategories.removeWhere(
                              (item) => item.id == id,
                            ),
                          );
                        }),
                      // Salgy düwmesi
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          final result =
                              await Navigator.push<List<SaylananSalgy>>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MainAddressPage(),
                                ),
                              );
                          if (result != null)
                            setState(() => selectedAddresses = result);
                        },
                        child: _selectBox(
                          context,
                          'Salgyny saýla',
                          Icons.location_on_outlined,
                        ),
                      ),

                      // Saýlanan salgylary
                      if (selectedAddresses.isNotEmpty)
                        _buildChipGroup(selectedAddresses, (id) {
                          setState(
                            () => selectedAddresses.removeWhere(
                              (item) => item.id == id,
                            ),
                          );
                        }),
                      // TextField lar
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _priceField(minPriceCtr, 'Min Baha')),
                          const SizedBox(width: 10),
                          Expanded(child: _priceField(maxPriceCtr, 'Max Baha')),
                        ],
                      ),

                      SizedBox(height: h / 84.4),
                      _buildSearchButton(context),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _applyFilter,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Gözle',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1,
            fontSize: 10,
            fontFamily: "Bricolage",
          ),
        ),
      ),
    );
  }

  void _applyFilter() {
    List<String> filterParts = [];

    if (minPriceCtr.text.isNotEmpty) {
      filterParts.add('min=${minPriceCtr.text}');
    }
    if (maxPriceCtr.text.isNotEmpty) {
      filterParts.add('max=${maxPriceCtr.text}');
    }

    // Saýlanan kategoriýalar bar bolsa
    if (selectedSubcategories.isNotEmpty) {
      final categoryIds = selectedSubcategories.map((e) => e.id).join(',');
      filterParts.add('category=$categoryIds');
    }

    // Saýlanan salgylary bar bolsa
    if (selectedAddresses.isNotEmpty) {
      final addressIds = selectedAddresses.map((e) => e.id).join(',');
      filterParts.add('address=$addressIds');
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
              fontFamily: "Bricolage",
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

  Widget _priceField(TextEditingController ctr, String label) {
    return TextField(
      controller: ctr,
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontSize: 12,
        fontFamily: 'Bricolage',
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        prefixIcon: Icon(
          Icons.payment_outlined,
          color: Theme.of(context).colorScheme.secondary,
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
}
