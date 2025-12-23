import 'package:flutter/material.dart';
import 'package:seyir/api/fetch_logist.dart';
import 'package:seyir/component/navbar.dart';
import 'package:seyir/pages/logist/create/create_logist.dart';
import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';

class LogistCategoryPage extends StatefulWidget {
  const LogistCategoryPage({super.key});
  @override
  State<LogistCategoryPage> createState() => _LogistCategoryPageState();
}

class _LogistCategoryPageState extends State<LogistCategoryPage> {
  late Future<List<LogistCategory>> _categoriesFuture;
  List<SaylananCategory> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = fetchCategories();
  }

  void _save() {
    if (!mounted) return;
    // Возвращаем выбранные категории на предыдущий экран
    Navigator.pop(context, selectedCategories);
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
                shape: RoundedRectangleBorder(side: BorderSide.none),
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                collapsedShape: RoundedRectangleBorder(side: BorderSide.none),
                children:
                    category.subcategories.map((sub) {
                      final isSelected = selectedCategories.any(
                        (item) => item.id == sub.pk,
                      );

                      return CheckboxListTile(
                        title: Text(
                          sub.name,
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
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true && !isSelected) {
                              selectedCategories.add(
                                SaylananCategory(id: sub.pk, name: sub.name),
                              );
                            } else if (checked == false) {
                              selectedCategories.removeWhere(
                                (item) => item.id == sub.pk,
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
        onPressed: selectedCategories.isEmpty ? null : _save,
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
