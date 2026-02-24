// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:seyir/pages/create/address_list.dart';
import 'package:seyir/api/fetch_spare.dart';
import 'package:seyir/pages/create/category_list.dart';
import 'package:seyir/widgets/fields/price_text_field.dart';
import 'dart:developer';
import 'dart:io';
import '../../utils/constants.dart';
import '../../widgets/fields/phone_text_field.dart';
import '../../widgets/fields/textArea.dart';
import '../../widgets/fields/text_field.dart';
import '../../component/navbar.dart';
import '../../utils/models.dart';

class UpdateSpare extends StatefulWidget {
  final int? id;
  final bool isEditing;
  const UpdateSpare({Key? key, this.id, this.isEditing = false})
    : super(key: key);

  @override
  _UpdateSpareState createState() => _UpdateSpareState();
}

class _UpdateSpareState extends State<UpdateSpare> {
  // Modelde bar bolan täze controller-lar
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();
  TextEditingController priceCtr = TextEditingController();
  TextEditingController yearCtr = TextEditingController();
  TextEditingController colorCtr = TextEditingController();

  TextEditingController partNumberCtr = TextEditingController();
  TextEditingController compatibilityCtr =
      TextEditingController(); // Uýgunlaşyjylyk
  String selectedCondition = 'used'; // Default bahasy
  final bool _validate = false;
  String suratText = '';

  late Future<SpareDetailModel> futureData;

  // Saýlamaly parametrler (Choices)
  String? selectedGearbox;
  String? selectedFuel;
  String? selectedColor;
  String? selectedYear;

  List<dynamic> existingImages =
      []; // Backend-den gelen URL-ler (String ýa-da Model)
  List<XFile> newPickedImages = []; // Täze saýlanan faýllar
  List<String> deletedImageIds = []; // Ulanyjynyň öçüren suratlarynyň ID-leri
  final ImagePicker _picker = ImagePicker();
  final List<dynamic> _imageFileList = [];
  final String defaultImagePath = 'assets/no-image.jpg';

  List<SaylananCategory> selectedCategories = [];
  List<SaylananSalgy> selectedAddresses = [];
  String author = '';
  final _appToken = Hive.box('apptoken');
  bool isDataLoaded = false;
  bool isMainImageDeleted = false;

  @override
  void initState() {
    super.initState();
    author = _appToken.get('token', defaultValue: '');
    futureData = getSpareDetailApi(widget.id!);

    if (widget.isEditing && widget.id != null) {
      _loadData(); // API-dan maglumat alyp doldurjak funksiýamyz
    }
  }

  Future<void> _loadData() async {
    try {
      // API-dan maglumaty garaşyp alýarys
      SpareDetailModel data = await getSpareDetailApi(widget.id!);

      // Gelen maglumaty meýdançalara ýerleşdirýäris
      setState(() {
        _fillFields(data);
        log(data.toString());
      });
    } catch (e) {
      debugPrint("Maglumat ýüklenende ýalňyşlyk: $e");
      // Isleseňiz bärde ulanyja ýalňyşlyk barada dialog görkezip bilersiňiz
    }
  }

  void _fillFields(SpareDetailModel data) {
    if (isDataLoaded) return;

    titleCtr.text = data.title;
    priceCtr.text = data.price;
    phoneCtr.text = data.phone;
    descCtr.text = data.desc;

    // Zapçast üçin täze meýdançalar
    partNumberCtr.text = data.partNumber ?? '-';
    compatibilityCtr.text = data.compatibility ?? '';
    selectedYear = data.year?.toString() ?? '2000';
    selectedCondition = data.condition ?? 'used';

    // Kategoriýa we Salgy
    if (data.category_id.isNotEmpty) {
      selectedCategories = [
        SaylananCategory(id: int.parse(data.category_id), name: data.category),
      ];
    }
    if (data.address_id.isNotEmpty) {
      selectedAddresses = [
        SaylananSalgy(id: int.parse(data.address_id), name: data.address),
      ];
    }

    _imageFileList.clear();
    if (data.img.isNotEmpty) {
      _imageFileList.add(data.img); // Bu String bolar
    }

    // 2. Goşmaça suratlary (images) goşmak.
    // Bular eýýäm PK we URL bolan obyektler/maplar.
    if (data.images.isNotEmpty) {
      _imageFileList.addAll(data.images);
    }
    log(_imageFileList.toString());
    log('Images:' + data.images.toString());

    isDataLoaded = true;
  }

  // Surat saýlamak funksiýasy
  void selectedImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 50);
    if (images.isNotEmpty) {
      setState(() {
        if (_imageFileList.length + images.length <= 5) {
          _imageFileList.addAll(images);
        } else {
          // Limit duýduryşy
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Eger üýtgetmek tertibi bolsa we maglumat entek çekilmedik bolsa FutureBuilder ulanýarys
    if (widget.isEditing) {
      return FutureBuilder<SpareDetailModel>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Ýalňyşlyk: ${snapshot.error}")),
            );
          } else if (snapshot.hasData) {
            // Maglumat gelen badyna controller-lary doldurýarys
            _fillFields(snapshot.data!);
            return _buildMainForm(context);
          }
          return const Scaffold(
            body: Center(
              child: Text(
                "Maglumat tapylmady",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: "Bricolage",
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        },
      );
    }
    // Täze goşmak tertibi bolsa göni formany görkez
    return _buildMainForm(context);
  }

  Widget _buildMainForm(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: theme.colorScheme.background, // Background reňki
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          title: Text(
            'Awto şaýlary üýtgetmek',
            style: const TextStyle(
              fontFamily: "Bricolage",
              letterSpacing: 2,
              color: Colors.white,
              fontSize: 16,
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
          backgroundColor: theme.colorScheme.primary,
          centerTitle: true,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: height(context) / 56.27),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height(context) / 84.4),
              TextFieldCustom(ctr: titleCtr, text: 'Ady', validate: _validate),
              SizedBox(height: height(context) / 84.4),

              // Zapçast belgisi (Part Number) - TÄZE GOŞULAN
              TextFieldCustom(
                ctr: partNumberCtr,
                text: 'Zapçast belgisi (Part Number)',
                validate: false,
              ),
              SizedBox(height: height(context) / 84.4),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PhoneTextFieldCustom(ctr: phoneCtr, validate: _validate),
                  PriceTextFieldCustom(ctr: priceCtr, validate: _validate),
                ],
              ),
              SizedBox(height: height(context) / 84.4),

              Row(
                children: [
                  Expanded(child: _buildYearDropdown(context)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildConditionDropdown(context)),
                ],
              ),
              SizedBox(height: height(context) / 84.4),

              TextArea(descCtr: descCtr), // Umumy giňişleýin maglumat
              SizedBox(height: height(context) / 84.4),

              /// Salgy we Kategoriýa
              _buildSelectionButton(
                title:
                    selectedAddresses.isEmpty
                        ? 'Salgy saýla'
                        : 'Saýlanan salgy: ${selectedAddresses.first.name}',
                icon: CupertinoIcons.location_solid,
                onTap: () async {
                  final result = await Navigator.push<List<SaylananSalgy>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainAddressPage(),
                    ), // Bu ýerde hem Radio ulanmaly
                  );
                  if (result != null && result.isNotEmpty) {
                    setState(() {
                      // Öňkini arassala we diňe täzesini goş
                      selectedAddresses = [result.first];
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              _buildSelectionButton(
                title:
                    selectedCategories.isEmpty
                        ? 'Kategoriýa saýla'
                        : 'Saýlanan: ${selectedCategories.first.name}',
                icon: CupertinoIcons.list_bullet,
                onTap: () async {
                  final result = await Navigator.push<List<SaylananCategory>>(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              CategoryListPage(queryName: 'atiyaclik-saylar'),
                    ),
                  );
                  if (result != null && result.isNotEmpty) {
                    setState(() {
                      // Öňkini arassala we diňe täzesini goş
                      selectedCategories = [result.first];
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              SizedBox(height: height(context) / 84.4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: _imageFileList.length > 3 ? 450 : 250,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(99, 99, 99, 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildImagePicker(theme),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: height(context) / 84.4,
                  bottom: 12,
                ),
                width: width(context),
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    _handleSave();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  child: const Text(
                    'Maglumaty ýatda sakla',
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
        ),
      ),
    );
  }

  Widget _buildSelectionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: _buildSelectionContainer(context, title, icon),
    );
  }

  Widget _buildSelectionContainer(
    BuildContext context,
    String text,
    IconData icon,
  ) {
    return Container(
      height: 45,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(99, 99, 99, 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: "Bricolage",
                fontSize: 13,
                color: Theme.of(context).colorScheme.secondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildYearDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer, // Içki reňki
        borderRadius: BorderRadius.circular(12), // Burçlary
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Kölegäniň reňki
            blurRadius: 8, // Ýaýramagy
            offset: const Offset(0, 4), // Aşak süýşmegi
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              width: 2,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 1,
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
      ),
    );
  }

  Widget _buildConditionDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value:
            ['new', 'used', 'refurbished'].contains(selectedCondition)
                ? selectedCondition
                : 'used',
        dropdownColor: Theme.of(context).colorScheme.primaryContainer,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 14,
          fontFamily: 'Bricolage',
        ),
        decoration: InputDecoration(
          labelText: "Zapçastyň ýagdaýy",
          labelStyle: TextStyle(
            fontSize: 12,
            fontFamily: "Bricolage",
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
          filled: true,
          fillColor: Colors.transparent, // Konteýneriň reňki bar
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border:
              InputBorder.none, // Konteýner dizaýny bar diýip none edip bileris
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        items: [
          _buildConditionItem('new', 'Täze', Icons.fiber_new, Colors.green),
          _buildConditionItem('used', 'Ulanylan', Icons.history, Colors.orange),
          _buildConditionItem(
            'refurbished',
            'Dikelden',
            Icons.build_circle,
            Colors.blue,
          ),
        ],
        onChanged: (val) {
          setState(() {
            selectedCondition = val!;
          });
        },
      ),
    );
  }

  DropdownMenuItem<String> _buildConditionItem(
    String value,
    String text,
    IconData icon,
    Color color,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
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

  Widget _buildImagePicker(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_imageFileList.length}/5 Surat",
                style: const TextStyle(fontSize: 12),
              ),
              IconButton(
                onPressed: selectedImages,
                icon: Icon(
                  CupertinoIcons.camera_fill,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          if (_imageFileList.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imageFileList.length,
                itemBuilder: (context, index) {
                  final image = _imageFileList[index];

                  // Surat URL-ini anyklamak
                  String imageUrl = "";
                  if (image is String) {
                    imageUrl = image; // Esasy surat (img)
                  } else if (image is ImageModel) {
                    imageUrl = image.url; // Goşmaça surat (obyekt)
                  } else if (image is XFile) {
                    imageUrl = image.path; // Täze saýlanan surat
                  }

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              image is XFile
                                  ? Image.file(
                                    File(image.path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.network(
                                    imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              defaultImagePath,
                                              width: 80,
                                              height: 80,
                                            ),
                                  ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              final removedItem = _imageFileList[index];

                              if (removedItem is String) {
                                // Eger String bolsa, bu hemişe esasy surat (img) hasaplanýar
                                isMainImageDeleted = true;
                              } else if (removedItem is ImageModel) {
                                // Goşmaça surat bolsa, PK-syny sanawa goşýarys
                                deletedImageIds.add(removedItem.pk.toString());
                              }

                              _imageFileList.removeAt(index);
                            });
                          },
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _handleSave() {
    // 1. Ýönekeý tekst meýdançalaryny barlamak
    if (titleCtr.text.isEmpty ||
        // phoneCtr.text.length < 12 || // +993 bilen barlanyňda
        priceCtr.text.isEmpty ||
        descCtr.text.isEmpty) {
      _showWarning("Hemme meýdançalary dolduryň!");
      return;
    }

    // 2. Kategoriýa we Salgy barlagy
    if (selectedCategories.isEmpty) {
      _showWarning("Kategoriýa saýlaň!");
      return;
    }
    if (selectedAddresses.isEmpty) {
      _showWarning("Salgyny saýlaň!");
      return;
    }

    // Ähli zat geçse, maglumaty ugrat
    _postedData();
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.w400,
            fontFamily: 'Bricolage',
            fontSize: 14,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  // API-e maglumat ibermek
  void _postedData() async {
    // Bahany san görnüşine öwürmek
    double? priceValue = double.tryParse(
      priceCtr.text.replaceAll(RegExp(r'[^0-9.]'), ''),
    );

    Map<String, dynamic> dataMap = {
      'name': titleCtr.text,
      'phone': phoneCtr.text,
      'text': descCtr.text, // Django tarapda 'text' diýlip garaşylýar
      'price': priceValue ?? 0.0,
      'year': int.tryParse(selectedYear ?? '2024'),
      'condition': selectedCondition,
      'part_number': partNumberCtr.text,
      'compatibility': compatibilityCtr.text,
      'category':
          selectedCategories.isNotEmpty ? selectedCategories.first.id : null,
      'address':
          selectedAddresses.isNotEmpty ? selectedAddresses.first.id : null,
      // Öçürilen suratlaryň ID-lerini ugradýarys
      'delete_images': deletedImageIds.join(','),
      'is_main_image_deleted': isMainImageDeleted ? "true" : "false",
    };

    dataMap.removeWhere((key, value) => value == null);
    FormData formData = FormData.fromMap(dataMap);

    // Täze saýlanan suratlary (XFile) ugratmak
    for (var item in _imageFileList) {
      if (item is XFile) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(item.path, filename: item.name),
          ),
        );

        // Eger 'img' (esasy surat) boş bolsa ýa-da ilkinji täze surat bolsa ugratmaly
        if (_imageFileList.whereType<XFile>().first == item) {
          formData.files.add(
            MapEntry('img', await MultipartFile.fromFile(item.path)),
          );
        }
      }
    }

    try {
      String url = '$baseUrl/spares/update/${widget.id}/';
      Response response = await Dio().patch(
        url,
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $author"}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushNamed(
          context,
          '/added_list',
        ); // Üstünlikli bolsa öňki sahypa gaýt
      }
    } catch (e) {
      print("Update Error: $e");
    }
  }
}
