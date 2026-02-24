// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:seyir/pages/logist/create/logistaddress.dart';
import 'package:seyir/pages/logist/create/logistcategory.dart';
import 'package:seyir/pages/logist/logist_main_list.dart';
import '../../widgets/fields/text_field_row.dart';
import '../../component/navbar.dart';
import '../../utils/models.dart';
import '../../api/fetches.dart';

class LogistFilterWidget extends StatefulWidget {
  // final bool? client;
  final List categories;

  const LogistFilterWidget({
    super.key,
    required this.categories,
    // required this.client,
  });

  @override
  _LogistFilterWidgetState createState() => _LogistFilterWidgetState();
}

class _LogistFilterWidgetState extends State<LogistFilterWidget> {
  final bool _validate = false;

  bool selectedGet = false;
  bool selectedBring = false;
  final String text = '';

  List<SaylananSalgy> selectedSubaddresses = [];
  List<SaylananCategory> selectedSubcategories = [];

  final TextEditingController whereCtr = TextEditingController();
  final TextEditingController nirdenCtr = TextEditingController();
  final TextEditingController minPrice = TextEditingController();
  final TextEditingController maxPrice = TextEditingController();

  Future<List<AddressPage>>? _addressesFuture;

  @override
  void initState() {
    super.initState();
    _addressesFuture = fetchAddress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: theme.colorScheme.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: _buildAppBar(context),
      ),
      body: FutureBuilder<List<AddressPage>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(size.height / 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- SALGY SAÝLAMA ---
                // _sectionTitle('Salgy'),

                /// --- KATEGORIÝA SAÝLAMA ---
                // _sectionTitle('Kategoriýa'),
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push<List<SaylananCategory>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LogistCategoryPage(),
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

                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push<List<SaylananSalgy>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LogistAddressPage(),
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

                const SizedBox(height: 16),

                /// --- ÝERLEŞÝÄN ÝERI (Nirden / Nirä) ---
                Row(
                  children: [
                    Expanded(
                      child: TextFieldRowCustom(
                        ctr: whereCtr,
                        text: 'Nirä',
                        validate: _validate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFieldRowCustom(
                        ctr: nirdenCtr,
                        text: 'Nirden',
                        validate: _validate,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// --- BAHA ARALYGY ---
                _sectionTitle('Baha aralygy'),
                Row(
                  children: [
                    Expanded(child: _priceField(minPrice, 'Min Baha')),
                    const SizedBox(width: 10),
                    Expanded(child: _priceField(maxPrice, 'Max Baha')),
                  ],
                ),

                const SizedBox(height: 16),

                /// --- SWITCHES ---
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSwitchRow('Alyp gitmelimi', selectedGet, (val) {
                        setState(() {
                          selectedGet = val;
                          if (val) selectedBring = false;
                        });
                      }),
                      _buildSwitchRow('Getirmelimi', selectedBring, (val) {
                        setState(() {
                          selectedBring = val;
                          if (val) selectedGet = false;
                        });
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// --- GÖZLE DÜWMESI ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    child: const Text(
                      'Gözle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: "Bricolage",
                        letterSpacing: 1,
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

  /// --- UI COMPONENTS ---

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text(
        'Filter Gözlegi',
        style: TextStyle(
          // fontStyle: FontStyle.italic,
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
        labelText: text,
        // hintText:_phoneNumber.get(1),
        labelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.secondary,
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

  Widget _buildSwitchRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // Fon reňki saýlanylanda birneme üýtgeýär
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              value
                  ? theme.colorScheme.primary.withOpacity(0.4)
                  : theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "Bricolage",
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                if (value)
                  Text(
                    "Saýlandy",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: "Bricolage",
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch.adaptive(
              value: value,
              activeColor: theme.colorScheme.primary,
              activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[200],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    List<String> parts = [];

    if (nirdenCtr.text.isNotEmpty) parts.add('nirden=${nirdenCtr.text}');
    if (whereCtr.text.isNotEmpty) parts.add('where=${whereCtr.text}');
    if (minPrice.text.isNotEmpty) parts.add('min=${minPrice.text}');
    if (maxPrice.text.isNotEmpty) parts.add('max=${maxPrice.text}');

    // ID-leri dogry formatda ugratmak
    if (selectedSubcategories.isNotEmpty) {
      final catIds = selectedSubcategories.map((e) => e.id).join(',');
      parts.add('category=$catIds');
    }

    if (selectedSubaddresses.isNotEmpty) {
      final addrIds = selectedSubaddresses.map((e) => e.id).join(',');
      parts.add('address=$addrIds');
    }

    if (selectedBring) {
      parts.add('bring=True');
    } else if (selectedGet) {
      parts.add('bring=False');
    }

    String filter = parts.isNotEmpty ? '&${parts.join('&')}' : '';
    log("Generated Filter: $filter");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LogistMainList(filter: filter)),
    );
  }
}
