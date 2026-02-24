import 'package:flutter/material.dart';
import 'package:seyir/api/fetches.dart';
import 'package:seyir/component/navbar.dart';
import 'package:seyir/pages/logist/create/create_logist.dart';
import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';

class LogistAddressPage extends StatefulWidget {
  const LogistAddressPage({super.key});
  @override
  State<LogistAddressPage> createState() => _LogistAddressPageState();
}

class _LogistAddressPageState extends State<LogistAddressPage> {
  late Future<List<AddressPage>> _addressesFuture;
  List<SaylananSalgy> selectedSubaddresses = [];

  @override
  void initState() {
    super.initState();
    _addressesFuture = fetchAddress();
  }

  void _save() async {
    if (!mounted) return;
    // Возвращаем выбранные адреса на предыдущий экран
    Navigator.pop(context, selectedSubaddresses);
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
                shape: RoundedRectangleBorder(side: BorderSide.none),
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                collapsedShape: RoundedRectangleBorder(side: BorderSide.none),
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
                            return Theme.of(context).colorScheme.primary;
                          }
                          return Colors.grey;
                        }),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              if (!isSelected) {
                                selectedSubaddresses.add(
                                  SaylananSalgy(
                                    id: int.parse(sub.id),
                                    name: sub.title,
                                  ),
                                );
                              }
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
        onPressed: selectedSubaddresses.isEmpty ? null : _save,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
