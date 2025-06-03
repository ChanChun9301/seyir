import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:seyir/component/navbar.dart';
import 'package:seyir/pages/logist/create_logist.dart';
import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';
import 'package:hive/hive.dart';

class LogistCategoryPage extends StatefulWidget {
  const LogistCategoryPage({Key? key}) : super(key: key);
  @override
  State<LogistCategoryPage> createState() => _LogistCategoryPageState();
}

class _LogistCategoryPageState extends State<LogistCategoryPage> {
  late Future<List<LogistCategory>> _categoriesFuture;
  late List<SaylananCategory> selectedCategories;

  Future<void> saveSelectedCategories(List<SaylananCategory> list) async {
    final box = Hive.box<SaylananCategory>('selected_categories');
    await box.clear();
    for (var item in list) {
      await box.add(item);
    }
  }

  @override
  void initState() {
    super.initState();
    selectedCategories = [];
    _categoriesFuture = fetchCategories();
  }

  void _save() async {
    await saveSelectedCategories(selectedCategories);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateLog()),
    );
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
            'Kategoriýalar',
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
      body: FutureBuilder<List<LogistCategory>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Ýalňyşlyk ýüze çykdy"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Maglumat ýok"));
          }

          final categories = snapshot.data!;
          final mainCategories =
              categories.where((cat) => cat.subcategories.isNotEmpty).toList();

          return ListView.builder(
            itemCount: mainCategories.length,
            itemBuilder: (context, index) {
              final category = mainCategories[index];
              return ExpansionTile(
                title: Text(
                  category.name,
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
                    category.subcategories.map((sub) {
                      return CheckboxListTile(
                        title: Text(
                          sub.name,
                          style: TextStyle(
                            fontFamily: 'Bricolage',
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        value: selectedSubcategories.any(
                          (item) => item.id == sub.pk,
                        ),
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
                              selectedSubcategories.add(
                                SaylananCategory(id: sub.pk, name: sub.name),
                              );
                            } else {
                              selectedSubcategories.removeWhere(
                                (item) => item.id == sub.pk,
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
        onPressed: _save,
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

Future<List<LogistCategory>> fetchCategories() async {
  final response = await http.get(Uri.parse('$baseUrl/logistcategory-list/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => LogistCategory.fromJson(e)).toList();
  } else {
    throw Exception('Kategoriýalar ýükläp bolmady');
  }
}
