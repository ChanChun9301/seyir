import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:seyir/component/navbar.dart';
import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';

class MainAddressPage extends StatefulWidget {
  const MainAddressPage({Key? key}) : super(key: key);

  @override
  State<MainAddressPage> createState() => _MainAddressPageState();
}

class _MainAddressPageState extends State<MainAddressPage> {
  late Future<List<AddressPage>> _addressesFuture;
  List<SaylananSalgy> selectedSubaddresses = [];

  @override
  void initState() {
    super.initState();
    _addressesFuture = fetchAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: const NavBar(),
      appBar: AppBar(
        title: const Text('Salgylar'),
        backgroundColor: Theme.of(context).colorScheme.primary,
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

          final addresses =
              snapshot.data!.where((e) => e.subaddresses.isNotEmpty).toList();

          return ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];

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
                backgroundColor: Colors.transparent, // Arkafon reňki göni
                collapsedBackgroundColor: Colors.transparent,
                collapsedShape: RoundedRectangleBorder(
                  side: BorderSide.none, // Çökelen ýagdaýda border ýok
                ),

                children:
                    address.subaddresses.map((sub) {
                      final isSelected = selectedSubaddresses.any(
                        (item) => item.id == int.parse(sub.id),
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
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedSubaddresses.add(
                                SaylananSalgy(
                                  id: int.parse(sub.id),
                                  name: sub.title,
                                ),
                              );
                            } else {
                              selectedSubaddresses.removeWhere(
                                (item) => item.id == int.parse(sub.id),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context, selectedSubaddresses);
        },
        icon: const Icon(Icons.check),
        label: const Text("Ýatda sakla"),
      ),
    );
  }
}

Future<List<AddressPage>> fetchAddress() async {
  final response = await http.get(Uri.parse('$baseUrl/addresses/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => AddressPage.fromJson(e)).toList();
  } else {
    throw Exception('Salgylar ýükläp bolmady');
  }
}
