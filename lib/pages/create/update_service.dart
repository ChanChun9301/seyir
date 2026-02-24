// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:seyir/pages/create/address_list.dart';
import 'package:seyir/api/fetch_service.dart';
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

class UpdateService extends StatefulWidget {
  final int? id;
  final bool isEditing;
  const UpdateService({Key? key, this.id, this.isEditing = false})
    : super(key: key);

  @override
  _UpdateServiceState createState() => _UpdateServiceState();
}

class _UpdateServiceState extends State<UpdateService> {
  // Modelde bar bolan täze controller-lar
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();
  TextEditingController priceCtr = TextEditingController();
  TextEditingController yearCtr = TextEditingController();
  TextEditingController colorCtr = TextEditingController();
  TextEditingController mileageCtr = TextEditingController();
  TextEditingController engineCtr = TextEditingController();
  TextEditingController vinCtr = TextEditingController();

  late Future<DetailModel> futureData;

  // Saýlamaly parametrler (Choices)
  String? selectedGearbox;
  String? selectedFuel;
  String? selectedColor;
  String? selectedYear;

  final ImagePicker _picker = ImagePicker();
  final List<dynamic> _imageFileList = [];
  final String defaultImagePath = 'assets/no-image.jpg';
  List<String> deletedImageIds = []; // Pozuljak suratlaryň ID-leri
  bool isMainImageDeleted = false;

  List<SaylananCategory> selectedCategories = [];
  List<SaylananSalgy> selectedAddresses = [];
  String author = '';
  final _appToken = Hive.box('apptoken');
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    author = _appToken.get('token', defaultValue: '');
    futureData = getServiceDetailApi(widget.id!);

    if (widget.isEditing && widget.id != null) {
      _loadData(); // API-dan maglumat alyp doldurjak funksiýamyz
    }
  }

  Future<void> _loadData() async {
    try {
      // API-dan maglumaty garaşyp alýarys
      DetailModel data = await getServiceDetailApi(widget.id!);

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

  void _fillFields(DetailModel data) {
    if (isDataLoaded) return;

    titleCtr.text = data.title;
    descCtr.text = data.desc;
    phoneCtr.text = data.phone;
    priceCtr.text = data.price;

    // Kategoriýany doldurmak
    if (data.category.isNotEmpty) {
      selectedCategories = [
        SaylananCategory(
          id: int.tryParse(data.category_id) ?? 0,
          name: data.category,
        ),
      ];
    }

    // Salgyny doldurmak
    if (data.address.isNotEmpty) {
      selectedAddresses = [
        SaylananSalgy(
          id: int.tryParse(data.address_id) ?? 0,
          name: data.address,
        ),
      ];
    }

    // Suratlary doldurmak (Köne URL-ler String hökmünde goşulýar)
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
      return FutureBuilder<DetailModel>(
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
            body: Center(child: Text("Maglumat tapylmady")),
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
            'Hyzmaty üýtgetmek',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionTitle("Esasy maglumatlar"),
            TextFieldCustom(
              ctr: titleCtr,
              text: 'Ulagyň ady (Meselem: Toyota Camry)',
              validate: false,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PhoneTextFieldCustom(ctr: phoneCtr, validate: false),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PriceTextFieldCustom(ctr: priceCtr, validate: false),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 16),
            // Salgy we Kategoriýa düwmeleri...
            _buildSelectionButton(
              title:
                  selectedAddresses.isEmpty
                      ? 'Salgy saýla'
                      : 'Saýlanan: ${selectedAddresses.first.name}',
              icon: CupertinoIcons.location_solid,
              onTap: _selectAddress,
            ),
            const SizedBox(height: 10),
            _buildSelectionButton(
              title:
                  selectedCategories.isEmpty
                      ? 'Kategoriýa saýla'
                      : 'Saýlanan: ${selectedCategories.first.name}',
              icon: CupertinoIcons.list_bullet,
              onTap: _selectCategory,
            ),
            const SizedBox(height: 16),
            TextArea(descCtr: descCtr),
            const SizedBox(height: 16),
            _buildImagePicker(theme),
            const SizedBox(height: 24),
            // SAKLAMAK DÜWMESI
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _postedData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.isEditing ? 'ÜÝTGETMELERI SAKLA' : 'ULAGY GOŞ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCategory() async {
    // CategoryListPage-e gidýäris we netijä garaşýarys
    final result = await Navigator.push<List<SaylananCategory>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => CategoryListPage(
              queryName: 'hyzmatlar',
            ), // 'ulaglar' seniň API slug-yň bolup biler
      ),
    );

    // Eger kategoriýa saýlanan bolsa, ony setState bilen täzeleýäris
    if (result != null && result.isNotEmpty) {
      setState(() {
        // Bizde diňe bir kategoriýa bolmaly (Radio button logikasy ýaly)
        selectedCategories = [result.first];
      });
    }
  }

  Future<void> _selectAddress() async {
    final result = await Navigator.push<List<SaylananSalgy>>(
      context,
      MaterialPageRoute(builder: (_) => const MainAddressPage()),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        // Bizde diňe bir salgy bolmaly bolsa, listi täzeleýäris
        selectedAddresses = [result.first];
      });
    }
  }

  // UI üçin kömekçi funksiýalar
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Bricolage',
            color: Theme.of(context).colorScheme.secondary,
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

  // API-e maglumat ibermek
  void _postedData() async {
    // 1. Validasiýa
    if (titleCtr.text.isEmpty ||
        selectedCategories.isEmpty ||
        selectedAddresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Hyzmatyň adyny, kategoriýasyny we salgysyny hökman saýlaň!",
          ),
        ),
      );
      return;
    }

    // 2. Data Map (Hyzmatlar üçin)
    Map<String, dynamic> dataMap = {
      'name': titleCtr.text,
      'phone': phoneCtr.text,
      'text': descCtr.text,
      'price': priceCtr.text.replaceAll(RegExp(r'[^0-9.]'), ''),
      'category': selectedCategories.first.id,
      'address': selectedAddresses.first.id,
      'author': author,
      'delete_images': deletedImageIds.join(','),
      'is_main_image_deleted': isMainImageDeleted ? "true" : "false",
    };

    FormData formData = FormData.fromMap(dataMap);

    // Täze suratlary (XFile) goşmak
    for (var file in _imageFileList) {
      if (file is XFile) {
        var multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
        formData.files.add(MapEntry('images', multipartFile));
      }
    }

    try {
      Response response = await Dio().patch(
        '$baseUrl/hyzmatlar/update/${widget.id}/',
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $author"}),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Üstünlikli bolsa yza dön
      }
    } catch (e) {
      log("Ýalňyşlyk: $e");
    }
  }
}
