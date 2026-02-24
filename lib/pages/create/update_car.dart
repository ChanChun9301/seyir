// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:seyir/pages/create/address_list.dart';
import 'package:seyir/api/fetch_car.dart';
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

class UpdateCar extends StatefulWidget {
  final int? id;
  final bool isEditing;
  const UpdateCar({Key? key, this.id, this.isEditing = false})
    : super(key: key);

  @override
  _UpdateCarState createState() => _UpdateCarState();
}

class _UpdateCarState extends State<UpdateCar> {
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

  late Future<CarDetailModel> futureData;

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
    futureData = getCarDetailApi(widget.id!);

    if (widget.isEditing && widget.id != null) {
      _loadData(); // API-dan maglumat alyp doldurjak funksiýamyz
    }
  }

  Future<void> _loadData() async {
    try {
      // API-dan maglumaty garaşyp alýarys
      CarDetailModel data = await getCarDetailApi(widget.id!);

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

  void _fillFields(CarDetailModel data) {
    if (isDataLoaded) return;

    titleCtr.text = data.name;
    priceCtr.text = data.price;
    phoneCtr.text = data.phone;
    descCtr.text = data.description ?? '';
    mileageCtr.text = data.mileage?.toString() ?? '';
    engineCtr.text = data.engineVolume ?? '';
    vinCtr.text = data.vinCode ?? '';

    selectedYear = data.year?.toString();
    selectedColor = data.color;
    selectedGearbox = data.gearbox;
    selectedFuel = data.fuelType;

    // ID-leri hökman modelden almaly (0 goýmaly däl)
    if (data.categoryName.isNotEmpty) {
      selectedCategories = [
        SaylananCategory(
          id: int.tryParse(data.category_id.toString()) ?? 0,
          name: data.categoryName,
        ),
      ];
    }

    if (data.addressName.isNotEmpty) {
      selectedAddresses = [
        SaylananSalgy(
          id: int.tryParse(data.address_id.toString()) ?? 0,
          name: data.addressName,
        ),
      ];
    }

    // Suratlary goşmazdan öň listi arassalaň, gaýtalanmasyn
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
      return FutureBuilder<CarDetailModel>(
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
            widget.isEditing ? 'Ulagy üýtgetmek' : 'Awtoulag goşmak',
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
            _buildSectionTitle("Tehniki häsiýetnamalar"),
            Row(
              children: [
                Expanded(child: _buildYearDropdown(context)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFieldCustom(
                    ctr: engineCtr,
                    text: 'Motor',
                    validate: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Reňk Dropdown
                Expanded(
                  child: _buildStyledContainer(
                    context,
                    child: DropdownButtonFormField<String>(
                      dropdownColor: theme.colorScheme.primaryContainer,
                      value:
                          (selectedColor == null || selectedColor!.isEmpty)
                              ? null
                              : selectedColor,
                      decoration: _buildInputDecoration(
                        context,
                        'Ulagyň reňki',
                        Icons.palette_outlined,
                      ),
                      items: [
                        _buildColorItem('Ak', Colors.white),
                        _buildColorItem('Gara', Colors.black),
                        _buildColorItem('Kümüşsöw', const Color(0xFFC0C0C0)),
                        _buildColorItem('Çal', Colors.grey),
                        _buildColorItem('Gök', Colors.blue[900]!),
                        // ... beýleki reňkler
                      ],
                      onChanged: (val) => setState(() => selectedColor = val),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFieldCustom(
                    ctr: mileageCtr,
                    text: 'Geçen ýoly (km)',
                    validate: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Korobka we Ýangyç Dropdownlary...
            Row(
              children: [
                Expanded(
                  child: _buildStyledContainer(
                    context,
                    child: DropdownButtonFormField<String>(
                      value: selectedGearbox,
                      decoration: _buildInputDecoration(
                        context,
                        'Korobka',
                        Icons.settings_input_component,
                      ),
                      items: [
                        _buildDropdownItem(
                          'manual',
                          'Mehanika',
                          Icons.settings_input_component,
                        ),
                        _buildDropdownItem(
                          'automatic',
                          'Awtomat',
                          Icons.auto_mode,
                        ),
                      ],
                      onChanged: (val) => setState(() => selectedGearbox = val),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStyledContainer(
                    context,
                    child: DropdownButtonFormField<String>(
                      value: selectedFuel,
                      decoration: _buildInputDecoration(
                        context,
                        'Ýangyç',
                        Icons.local_gas_station,
                      ),
                      items: [
                        _buildFuelItem(
                          'gasoline',
                          'Benzin',
                          Icons.local_gas_station,
                          Colors.orange,
                        ),
                        _buildFuelItem(
                          'diesel',
                          'Dizel',
                          Icons.ev_station,
                          Colors.grey,
                        ),
                      ],
                      onChanged: (val) => setState(() => selectedFuel = val),
                    ),
                  ),
                ),
              ],
            ),
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
              queryName: 'ulaglar',
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

  // Dropdown-laryň daşyndaky dizaýn
  Widget _buildStyledContainer(BuildContext context, {required Widget child}) {
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
      child: child,
    );
  }

  // Dropdown-laryň içki bezegi
  InputDecoration _buildInputDecoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      labelStyle: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.secondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
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

  DropdownMenuItem<String> _buildFuelItem(
    String value,
    String text,
    IconData icon,
    Color color,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color), // Reňkli ikonka
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

  DropdownMenuItem<String> _buildDropdownItem(
    String value,
    String text,
    IconData icon,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ],
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

  DropdownMenuItem<String> _buildColorItem(
    String colorName,
    Color colorDisplay,
  ) {
    return DropdownMenuItem<String>(
      value: colorName,
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: colorDisplay,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 0.5),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            colorName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
              fontFamily: "Bricolage",
            ),
          ),
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
                  color: Theme.of(context).colorScheme.secondary,
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
                // _buildImagePicker içindäki ListView.builder-yň içini şuňa çalşyr:
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
    // 1. Validasiýa (Esasy meýdançalary barlaň)
    if (titleCtr.text.isEmpty ||
        priceCtr.text.isEmpty ||
        selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zerur meýdançalary dolduruň!")),
      );
      return;
    }

    // 2. Maglumatlary API formatyna öwürin
    // Decimal we Int meýdançalary üçin arassalaýyş
    double? price = double.tryParse(
      priceCtr.text.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    int? mileage = int.tryParse(
      mileageCtr.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    Map<String, dynamic> dataMap = {
      'name': titleCtr.text,
      'phone': phoneCtr.text,
      'description': descCtr.text,
      'price': price ?? 0.0,
      'year': int.tryParse(selectedYear!) ?? 2020,
      'color': selectedColor,
      'engine_volume': engineCtr.text, // Modeliňize görä String ýa-da Double
      'mileage': mileage ?? 0,
      'gearbox': selectedGearbox,
      'fuel_type': selectedFuel,
      'category':
          selectedCategories.isNotEmpty ? selectedCategories[0].id : null,
      'current_addr':
          selectedAddresses.isNotEmpty ? selectedAddresses[0].id : null,
      'vin_code': vinCtr.text,
      'delete_images': deletedImageIds.join(','),
      'is_main_image_deleted': isMainImageDeleted ? "true" : "false",
    };

    // Null bahalary aýyryň
    dataMap.removeWhere((key, value) => value == null);
    FormData formData = FormData.fromMap(dataMap);

    // 3. SURATLAR BÖLÜMI (Diňe täze saýlanan bolsa ugradýar)
    bool hasNewImage = false;
    for (var file in _imageFileList) {
      if (file is XFile) {
        String fileName = file.path.split('/').last;
        var multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        );

        // 1. Galereýa (Multi-image) üçin hemmesini goşýarys
        formData.files.add(MapEntry('images', multipartFile));

        // 2. Esasy surat (img) logikasy:
        // Eger sanawda birinji duran element täze saýlanan surat bolsa,
        // ony esasy surat hökmünde belleýäris.
        if (_imageFileList.first == file) {
          formData.files.add(MapEntry('img', multipartFile));
        }
      }
    }

    try {
      // 4. API Soragy (isEditing bolsa PATCH, bolmasa POST)
      String url = '$baseUrl/car/update/${widget.id}/';

      Response response = await Dio().request(
        url,
        data: formData,
        options: Options(
          method: widget.isEditing ? 'PATCH' : 'POST',
          headers: {
            "Authorization": "Bearer $author",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Täzelendi!")));
        Navigator.pop(
          context,
          true,
        ); // True ugradylsa, öňki sahypa Refresh bolar
      }
    } catch (e) {
      if (e is DioException) {
        log("API Ýalňyşlygy: ${e.response?.data}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.response?.data.toString()}")),
        );
      }
    }
  }
}
