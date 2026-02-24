import 'package:flutter/material.dart';
import 'package:seyir/component/navbar.dart';
import 'package:seyir/api/fetch_car.dart';
import 'package:seyir/utils/models.dart';
import 'package:hive/hive.dart';

class CategoryListPage extends StatefulWidget {
  final String? queryName;
  const CategoryListPage({Key? key, required this.queryName}) : super(key: key);

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  late Future<List<CategoryPage>> _categoriesFuture;

  // Saýlanan ýeke-täk kategoriýany saklamak üçin
  List<SaylananCategory> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = fetchCategories(widget.queryName ?? '');
  }

  // Maglumatlary yzyna ibermek
  void _save() {
    Navigator.pop(context, selectedCategories);
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
            'Kategoriýa saýla',
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
      body: FutureBuilder<List<CategoryPage>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Ýalňyşlyk ýüze çykdy"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Kategoriýa tapylmady"));
          }

          final categories = snapshot.data!;
          // Diňe subkategoriýasy bolan esasy kategoriýalary görkezmek
          final mainCategories =
              categories.where((cat) => cat.subcategories.isNotEmpty).toList();

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            itemCount: mainCategories.length,
            itemBuilder: (context, index) {
              final category = mainCategories[index];

              return ExpansionTile(
                iconColor: theme.colorScheme.primary,
                title: Text(
                  category.title,
                  style: TextStyle(
                    fontFamily: 'Bricolage',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                shape: const Border(), // ExpansionTile çyzyklaryny aýyrýar
                children:
                    category.subcategories.map((sub) {
                      // Diňe birini saýlap bolar ýaly RadioListTile
                      return RadioListTile<int>(
                        title: Text(
                          sub.name,
                          style: TextStyle(
                            fontFamily: 'Bricolage',
                            fontSize: 13,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        value: sub.pk,
                        // Eger şu ID sanawda bar bolsa, ony saýlanan diýip görkez
                        groupValue:
                            selectedCategories.isNotEmpty
                                ? selectedCategories.first.id
                                : null,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (int? value) {
                          setState(() {
                            selectedCategories.clear(); // Öňkini öçür
                            if (value != null) {
                              selectedCategories.add(
                                SaylananCategory(id: sub.pk, name: sub.name),
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

      // Ýatda sakla düwmesi
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedCategories.isEmpty ? null : _save,
        backgroundColor:
            selectedCategories.isEmpty
                ? Colors.grey
                : theme.colorScheme.primary,
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
