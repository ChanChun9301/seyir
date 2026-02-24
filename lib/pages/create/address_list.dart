import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:seyir/component/navbar.dart';
import 'package:seyir/utils/models.dart';
import 'package:seyir/api/fetches.dart';

class MainAddressPage extends StatefulWidget {
  const MainAddressPage({Key? key}) : super(key: key);

  @override
  State<MainAddressPage> createState() => _MainAddressPageState();
}

class _MainAddressPageState extends State<MainAddressPage> {
  late Future<List<AddressPage>> _addressesFuture;
  List<SaylananSalgy> selectedAddresses = [];

  @override
  void initState() {
    super.initState();
    _addressesFuture = fetchAddress();
  }

  void _save() {
    log('Selected:' + selectedAddresses.toString());
    Navigator.pop(context, selectedAddresses);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: const NavBar(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          backgroundColor: theme.colorScheme.primary,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Salgy saýla',
            style: TextStyle(
              fontFamily: "Bricolage",
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          leading: Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(
                    Icons.sort_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
        ),
      ),
      body: FutureBuilder<List<AddressPage>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Maglumat ýok"));
          }

          final addresses = snapshot.data!;
          final mainaAdresses =
              addresses.where((e) => e.subaddresses.isNotEmpty).toList();

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            itemCount: mainaAdresses.length,
            itemBuilder: (context, index) {
              final address = mainaAdresses[index];

              return ExpansionTile(
                iconColor: theme.colorScheme.primary,
                title: Text(
                  address.title,
                  style: TextStyle(
                    fontFamily: 'Bricolage',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide.none, // Açylan ýagdaýda hem border ýok
                ),
                backgroundColor: Colors.transparent, // Arkafon reňki göni
                collapsedBackgroundColor: Colors.transparent,
                collapsedShape: RoundedRectangleBorder(
                  side: BorderSide.none, // Çökelen ýagdaýda border ýok
                ),

                children:
                    address.subaddresses.map((sub) {
                      return RadioListTile<int>(
                        title: Text(
                          sub.title,
                          style: TextStyle(
                            fontFamily: 'Bricolage',
                            fontSize: 12,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        value: int.parse(sub.id),
                        shape: const Border(),
                        groupValue:
                            selectedAddresses.isNotEmpty
                                ? selectedAddresses.first.id
                                : null,
                        activeColor: theme.colorScheme.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (int? value) {
                          setState(() {
                            selectedAddresses.clear();
                            if (value != null) {
                              selectedAddresses.add(
                                SaylananSalgy(
                                  id: int.parse(sub.id),
                                  name: sub.title,
                                ),
                              );
                            }
                          });
                        },
                      );
                    }).toList(),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedAddresses.isEmpty ? null : _save,
        backgroundColor:
            selectedAddresses.isEmpty ? Colors.grey : theme.colorScheme.primary,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(
          "Saýlawy tassykla",
          style: TextStyle(
            fontFamily: 'Bricolage',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
