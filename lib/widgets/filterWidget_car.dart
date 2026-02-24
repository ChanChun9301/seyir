// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:seyir/pages/lists/main_list.dart';
import 'package:seyir/pages/lists/address_list.dart'; // Dogry importlar
import 'package:seyir/pages/lists/category_list.dart';
import '../../component/navbar.dart';
import '../../utils/models.dart';

class CarFilterWidget extends StatefulWidget {
  final String currentFilter;
  const CarFilterWidget({Key? key, required this.currentFilter})
    : super(key: key);

  @override
  _CarFilterWidgetState createState() => _CarFilterWidgetState();
}

class _CarFilterWidgetState extends State<CarFilterWidget> {
  final bool _validate = false;
  bool showSpinner = false;

  // Filter maglumatlary
  List<SaylananSalgy> selectedAddresses = [];
  List<SaylananCategory> selectedSubcategories = [];

  String? selectedGearbox;
  String? selectedFuel;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    _parseCurrentFilter();
  }

  @override
  void dispose() {
    minPriceCtr.dispose();
    maxPriceCtr.dispose();
    super.dispose();
  }

  String? selectedYear;
  final TextEditingController minPriceCtr = TextEditingController();
  final TextEditingController maxPriceCtr = TextEditingController();

  void _parseCurrentFilter() {
    if (widget.currentFilter.isEmpty) return;

    // Filter stringini dargatmak (Meselem: &color=Ak&gearbox=manual)
    // Garyşyk bolmazlygy üçin ilki '&' simwolyny '?' bilen çalşyryp bileris
    String normalized = widget.currentFilter.replaceFirst('&', '?');
    Uri uri = Uri.parse(normalized);
    Map<String, String> params = uri.queryParameters;

    setState(() {
      selectedColor = params['color'];
      selectedGearbox = params['gearbox'];
      selectedFuel = params['fuel_type'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const NavBar(),

      backgroundColor: theme.colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(
            'Filter Gözlegi',
            style: TextStyle(
              letterSpacing: 2,
              fontFamily: "Bricolage",
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 0,
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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
      ),
      body:
          showSpinner
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: h / 56.27),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// --- KATEGORIÝA ---
                      InkWell(
                        onTap: () async {
                          final result = await Navigator.push<
                            List<SaylananCategory>
                          >(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => CategoryListPage(queryName: 'ulaglar'),
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
                            setState(() => selectedAddresses = result);
                        },
                        child: _selectBox(
                          context,
                          'Salgyny saýla',
                          Icons.location_on_outlined,
                        ),
                      ),
                      if (selectedAddresses.isNotEmpty)
                        _buildChipGroup(selectedAddresses, (id) {
                          setState(
                            () => selectedAddresses.removeWhere(
                              (item) => item.id == id,
                            ),
                          );
                        }),

                      const SizedBox(height: 20),

                      /// --- BREND WE MODEL ---
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              icon: Icon(
                                Icons
                                    .palette_outlined, // Reňk palitrasy ikonkasy
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Ulagyň reňki',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontFamily: "Bricolage",
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              value:
                                  selectedColor == ''
                                      ? null
                                      : selectedColor, // Başlangyç baha
                              items: [
                                _buildColorItem('Ak', Colors.white),
                                _buildColorItem('Gara', Colors.black),
                                _buildColorItem(
                                  'Kümüşsöw',
                                  Color(0xFFC0C0C0),
                                ), // Silver
                                _buildColorItem('Çal', Colors.grey),
                                _buildColorItem('Gök', Colors.blue[900]!),
                                _buildColorItem(
                                  'Asmany gök',
                                  Colors.blue[300]!,
                                ),
                                _buildColorItem('Gyzyl', Colors.red[700]!),
                                _buildColorItem(
                                  'Goýy ýaşyl',
                                  Colors.green[900]!,
                                ),
                                _buildColorItem(
                                  'Altynsöw',
                                  Color(0xFFFFD700),
                                ), // Gold
                                _buildColorItem('Goňur', Colors.brown),
                                _buildColorItem('Mawy', Colors.cyan),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  selectedColor = val!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _buildYearDropdown(context)),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _sectionTitle('Baha aralygy'),
                      Row(
                        children: [
                          Expanded(child: _priceField(minPriceCtr, 'Min Baha')),
                          const SizedBox(width: 10),
                          Expanded(child: _priceField(maxPriceCtr, 'Max Baha')),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Birinji Dropdown
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
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontFamily: "Bricolage",
                              ),

                              decoration: InputDecoration(
                                labelText: 'Korobka',
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

                              value: selectedGearbox,
                              // Menýunyň içindäki elementleriň dizaýny
                              items: [
                                _buildDropdownItem(
                                  'manual',
                                  'Mehanika',
                                  Icons.settings_input_component,
                                ),
                                _buildDropdownItem(
                                  'automatic',
                                  'Awtomat',
                                  Icons.auto_mode,
                                ),
                                _buildDropdownItem(
                                  'hybrid',
                                  'Gibrid',
                                  Icons.electric_car,
                                ),
                              ],
                              onChanged:
                                  (val) =>
                                      setState(() => selectedGearbox = val),
                            ),
                          ),

                          const SizedBox(width: 10), // Aradaky boşluk
                          // Ikinji Dropdown
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
                                labelText: 'Ýangyç',
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

                              value: selectedFuel,
                              // Menýunyň içindäki elementleriň dizaýny
                              items: [
                                _buildFuelItem(
                                  'gasoline',
                                  'Benzin',
                                  Icons.local_gas_station,
                                  Colors.orange,
                                ),
                                _buildFuelItem(
                                  'diesel',
                                  'Dizel',
                                  Icons.ev_station,
                                  Colors.grey,
                                ),
                                _buildFuelItem(
                                  'electric',
                                  'Elektrik',
                                  Icons.bolt,
                                  Colors.blue,
                                ),
                                _buildFuelItem(
                                  'hybrid',
                                  'Gibrid',
                                  Icons.eco,
                                  Colors.green,
                                ),
                              ],
                              onChanged:
                                  (val) => setState(() => selectedFuel = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// --- GÖZLE DÜWMESI ---
                      _buildSearchButton(context),
                    ],
                  ),
                ),
              ),
    );
  }

  DropdownMenuItem<String> _buildColorItem(
    String colorName,
    Color colorDisplay,
  ) {
    return DropdownMenuItem<String>(
      value: colorName,
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: colorDisplay,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 0.5),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            colorName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
              fontFamily: "Bricolage",
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildFuelItem(
    String value,
    String text,
    IconData icon,
    Color color,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color), // Reňkli ikonka
          const SizedBox(width: 10),
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

  DropdownMenuItem<String> _buildDropdownItem(
    String value,
    String text,
    IconData icon,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSecondary,
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
                // width: width(context) / 5,
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
      maxLines: 1,
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
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildYearDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedYear,
      dropdownColor: Theme.of(context).colorScheme.primaryContainer,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontSize: 12,
        fontFamily: 'Bricolage',
      ),
      decoration: InputDecoration(
        labelText: "Goýberilen ýyly",
        labelStyle: TextStyle(
          fontSize: 12,
          fontFamily: "Bricolage",
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.secondary,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.primaryContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      items:
          List.generate(
                (DateTime.now().year - 1990) + 1,
                (index) => (DateTime.now().year - index).toString(),
              )
              .map(
                (year) => DropdownMenuItem(
                  value: year,
                  child: Text(
                    year,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              )
              .toList(),
      onChanged: (val) => setState(() => selectedYear = val),
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
    List<String> parts = [];
    if (selectedYear != null) parts.add('year=$selectedYear');
    if (selectedColor != null) parts.add('color=$selectedColor');
    if (selectedFuel != null) parts.add('fuel=$selectedFuel');
    if (selectedGearbox != null) parts.add('gearbox=$selectedGearbox');
    if (minPriceCtr.text.isNotEmpty) parts.add('min=${minPriceCtr.text}');
    if (maxPriceCtr.text.isNotEmpty) parts.add('max=${maxPriceCtr.text}');

    if (selectedSubcategories.isNotEmpty) {
      parts.add('category=${selectedSubcategories.map((e) => e.id).join(',')}');
    }
    if (selectedAddresses.isNotEmpty) {
      parts.add('address=${selectedAddresses.map((e) => e.id).join(',')}');
    }

    String filter = parts.isNotEmpty ? '&${parts.join('&')}' : '';
    log("Filter Query: $filter");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MainList(
              filter: filter,
              pageName: 'Awtoulaglar',
              queryName: 'car',
            ),
      ), // Ady düzedildi
    );
  }
}
