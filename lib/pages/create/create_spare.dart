// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:seyir/pages/create/address_list.dart';
import 'package:seyir/pages/create/category_list.dart';
import 'package:seyir/widgets/fields/price_text_field.dart';
import '../../utils/dialogs.dart';
import 'dart:developer';
import 'dart:io';
import '../../utils/constants.dart';
import '../../widgets/fields/phone_text_field.dart';
import '../../widgets/fields/textArea.dart';
import '../../widgets/fields/text_field.dart';
import '../../component/navbar.dart';
import '../../utils/models.dart';

class CreateSpare extends StatefulWidget {
  const CreateSpare({Key? key}) : super(key: key);

  @override
  _CreateSpareState createState() => _CreateSpareState();
}

class _CreateSpareState extends State<CreateSpare>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = now;

  final ImagePicker _picker = ImagePicker();
  final List<dynamic> _imageFileList = [];
  final String defaultImagePath = 'assets/no-image.jpg';
  Future<String> _copyAssetToTemp(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${(await getTemporaryDirectory()).path}/no-image.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  String suratText = '';
  final bool _validate = false;
  bool selectedVip = false;
  bool selectedBring = false;

  void selectedImages() async {
    final List<dynamic> selectedImages = await _picker.pickMultiImage(
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 600,
    );

    if (selectedImages.isNotEmpty) {
      _imageFileList.addAll(selectedImages);
    }
    setState(() {});
  }

  void deletImage(int index) {
    _imageFileList.removeAt(index);
    setState(() {});
  }

  TextEditingController titleCtr = TextEditingController();
  TextEditingController descCtr = TextEditingController();
  TextEditingController imgCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();
  TextEditingController whereCtr = TextEditingController();
  TextEditingController nirdenCtr = TextEditingController();
  TextEditingController priceCtr = TextEditingController();
  TextEditingController compatibilityCtr = TextEditingController();
  TextEditingController partNumberCtr = TextEditingController();
  String selectedCondition = 'used';
  String? selectedYear;
  String author = '';

  List<AddressPage> addresses = [];
  List<CategoryPage> categories = [];
  List<SaylananCategory> selectedCategories = [];
  List<SaylananSalgy> selectedAddresses = [];

  // bool showSpinner = false;
  final _appToken = Hive.box('apptoken');
  @override
  void initState() {
    super.initState();
    author = _appToken.get('token', defaultValue: '');
  }

  int index = 0;
  int count = 5;
  List<Map<String, dynamic>> items = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          title: Text(
            'Awto şaýlary goşmak',
            style: const TextStyle(
              letterSpacing: 2,
              fontFamily: "Bricolage",
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          notificationPredicate: (ScrollNotification notification) {
            return notification.depth == 1;
          },
          scrolledUnderElevation: 4.0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 10,
          centerTitle: true,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (_imageFileList.length <= 5)
                              ? '${_imageFileList.length} sany surat'
                              : 'siz 5-den artyk surat saýlap bilmeýärsiňiz',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontFamily: 'Bricolage',
                            fontSize: 10,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.camera_circle_fill,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 24,
                          ),
                          onPressed: () {
                            if (_imageFileList.length < 5) {
                              suratText = 'Surat saýla';
                              selectedImages();
                            } else {
                              suratText = 'Surat saýlamak limidi doly';
                            }
                          },
                          tooltip: suratText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SizedBox(
                        child: GridView.builder(
                          itemCount: _imageFileList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                              ),
                          itemBuilder: (BuildContext context, int index) {
                            return _imageFileList.isNotEmpty
                                ? Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      padding: const EdgeInsets.all(2),
                                      child: Image.file(
                                        File(_imageFileList[index].path),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Positioned(
                                      right: 3,
                                      top: 3,
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            deletImage(index);
                                          },
                                          icon: Icon(
                                            CupertinoIcons.delete,
                                            size: 10,
                                            color: Colors.red[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : const Center();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
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
                    Navigator.pushNamed(context, '/added_list');
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
        value: selectedCondition,
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

  void _postedData() async {
    if (_imageFileList.isEmpty) {
      String tempFilePath = await _copyAssetToTemp(defaultImagePath);
      _imageFileList.add(XFile(tempFilePath));
    }
    FormData formData = FormData.fromMap({
      'name': titleCtr.text,
      'phone': phoneCtr.text.substring(3), // +993 aýyrýar
      'author': author,
      'text': descCtr.text,
      'price': priceCtr.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      ), // Diňe sanlary ugratmak üçin
      // Django ForeignKey meýdanlary üçin köplenç List däl-de, ýeke ID garaşylýar
      'address': selectedAddresses.first.id,
      'category': selectedCategories.first.id,

      // ZAPÇAST ÜÇIN TÄZE MEÝDANÇALAR
      'part_number': partNumberCtr.text,
      'year': selectedYear, // Dropdown-dan gelen baha
      'condition': selectedCondition, // 'new', 'used' ýaly iňlisçe bahasy
      'compatibility': compatibilityCtr.text,

      'img': await MultipartFile.fromFile(_imageFileList[0].path),
      'images': [
        for (final image in _imageFileList.skip(
          1,
        )) // Birinji suraty 'img' hökmünde ugratdyk
          await MultipartFile.fromFile(image.path, filename: image.name),
      ],
    });

    Dio dio = Dio();
    try {
      Response response = await dio.post(
        '$baseUrl/spares/create/',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(snackBarFunc);
        Navigator.pushNamed(context, '/added_list');
      }
    } catch (e) {
      log("Ugratmakda ýalňyşlyk: $e");
      _showWarning("Serwerde ýalňyşlyk döredi!");
    }
  }

  void _handleSave() {
    // 1. Ýönekeý tekst meýdançalaryny barlamak
    if (titleCtr.text.isEmpty ||
        phoneCtr.text.length < 12 || // +993 bilen barlanyňda
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

  // Duýduryş üçin kiçijik funksiýa
  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
