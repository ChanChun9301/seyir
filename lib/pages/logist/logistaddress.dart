import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:seyir/component/navbar.dart';
import 'package:seyir/pages/logist/create_logist.dart';
import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';
import 'package:hive/hive.dart';

class LogistAddressPage extends StatefulWidget {
  const LogistAddressPage({Key? key}) : super(key: key);
  @override
  State<LogistAddressPage> createState() => _LogistAddressPageState();
}

class _LogistAddressPageState extends State<LogistAddressPage> {
  late Future<List<AddressPage>> _addressesFuture;
  late List<SaylananSalgy> selectedSubaddresses;

  Future<void> saveSelectedAddresses(List<SaylananSalgy> list) async {
    final box = Hive.box<SaylananSalgy>('selected_addresses');
    await box.clear();
    for (var item in list) {
      await box.add(item);
    }
  }

  @override
  void initState() {
    super.initState();
    selectedSubaddresses = [];
    _addressesFuture = fetchAddress();
  }

  void _save() async {
    final box = Hive.box<SaylananSalgy>('selected_addresses');
    await box.clear();
    for (var item in selectedSubaddresses) {
      await box.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          title: const Text(
            'Salgylar',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              letterSpacing: 2,
              fontFamily: "Bricolage",
              fontSize: 16,
              color: Colors.white,
            ),
          ),
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
      extendBodyBehindAppBar: true,
      drawer: const NavBar(),
      body: FutureBuilder<List<AddressPage>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Ýalňyşlyk ýüze çykdy"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Maglumat ýok"));
          }

          final addresses = snapshot.data!;
          final mainaddresses =
              addresses.where((cat) => cat.subaddresses.isNotEmpty).toList();

          return ListView.builder(
            itemCount: mainaddresses.length,
            itemBuilder: (context, index) {
              final address = mainaddresses[index];
              return ExpansionTile(
                title: Text(
                  address.title,
                  style: TextStyle(
                    fontFamily: 'Bricolage',
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide.none, // Açylan ýagdaýda hem border ýok
                ),
                // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundColor: Colors.transparent, // Arkafon reňki göni
                collapsedBackgroundColor: Colors.transparent,
                collapsedShape: RoundedRectangleBorder(
                  side: BorderSide.none, // Çökelen ýagdaýda border ýok
                ),
                children:
                    address.subaddresses.map((sub) {
                      final isSelected = selectedSubaddresses.any(
                        (item) => item.id.toString() == sub.id,
                      );
                      return CheckboxListTile(
                        title: Text(
                          sub.title,
                          style: TextStyle(
                            fontFamily: 'Bricolage',
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        value: isSelected,
                        activeColor: Theme.of(context).colorScheme.primary,
                        fillColor: MaterialStateProperty.resolveWith<Color>((
                          Set<MaterialState> states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return Theme.of(context)
                                .colorScheme
                                .primary; // seçilen ýagdaýda ikon reňki
                          }
                          return Colors.grey; // saýlanmadyk ýagdaýda ikon reňki
                        }),
                        checkColor: Colors.white,

                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              selectedSubaddresses.add(
                                SaylananSalgy(
                                  id: int.parse(sub.id),
                                  name: sub.title,
                                ),
                              );
                            } else {
                              selectedSubaddresses.removeWhere(
                                (item) => item.id == sub.id,
                              );
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _save;
          // if (!mounted) return;
          Navigator.pop(context);
        },
        label: Text(
          "Ýatda sakla",
          style: TextStyle(
            fontFamily: 'Bricolage',
            fontSize: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        icon: const Icon(Icons.check),
      ),
    );
  }
}

Future<List<AddressPage>> fetchAddress() async {
  final response = await http.get(Uri.parse('$baseUrl/address-list/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => AddressPage.fromJson(e)).toList();
  } else {
    throw Exception('Kategoriýalar ýükläp bolmady');
  }
}
