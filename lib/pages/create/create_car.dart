// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:seyir/pages/create/address_list.dart';
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

class CreateCar extends StatefulWidget {
  const CreateCar({Key? key}) : super(key: key);

  @override
  _CreateCarState createState() => _CreateCarState();
}

class _CreateCarState extends State<CreateCar> {
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

  // Saýlamaly parametrler (Choices)
  String? selectedGearbox;
  String? selectedFuel;
  String? selectedColor;
  String? selectedYear;

  final ImagePicker _picker = ImagePicker();
  final List<dynamic> _imageFileList = [];
  final String defaultImagePath = 'assets/no-image.jpg';

  List<SaylananCategory> selectedCategories = [];
  List<SaylananSalgy> selectedAddresses = [];
  String author = '';
  final _appToken = Hive.box('apptoken');

  @override
  void initState() {
    super.initState();
    author = _appToken.get('token', defaultValue: '');
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
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Awtoulag goşmak',
          style: TextStyle(
            fontFamily: "Bricolage",
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Esasy Maglumatlar
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

            /// Tehniki häsiýetnamalar (Täze goşulan)
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
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(
                            context,
                          ).colorScheme.primaryContainer, // Içki reňki
                      borderRadius: BorderRadius.circular(12), // Burçlary
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.1,
                          ), // Kölegäniň reňki
                          blurRadius: 8, // Ýaýramagy
                          offset: const Offset(0, 4), // Aşak süýşmegi
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      dropdownColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      icon: Icon(
                        Icons.palette_outlined, // Reňk palitrasy ikonkasy
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Ulagyň reňki',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontFamily: "Bricolage",
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value:
                          selectedColor == ''
                              ? null
                              : selectedColor, // Başlangyç baha
                      items: [
                        _buildColorItem('Ak', Colors.white),
                        _buildColorItem('Gara', Colors.black),
                        _buildColorItem(
                          'Kümüşsöw',
                          Color(0xFFC0C0C0),
                        ), // Silver
                        _buildColorItem('Çal', Colors.grey),
                        _buildColorItem('Gök', Colors.blue[900]!),
                        _buildColorItem('Asmany gök', Colors.blue[300]!),
                        _buildColorItem('Gyzyl', Colors.red[700]!),
                        _buildColorItem('Goýy ýaşyl', Colors.green[900]!),
                        _buildColorItem('Altynsöw', Color(0xFFFFD700)), // Gold
                        _buildColorItem('Goňur', Colors.brown),
                        _buildColorItem('Mawy', Colors.cyan),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedColor = val!;
                        });
                      },
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
            Row(
              children: [
                // Birinji Dropdown
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(
                            context,
                          ).colorScheme.primaryContainer, // Içki reňki
                      borderRadius: BorderRadius.circular(12), // Burçlary
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.1,
                          ), // Kölegäniň reňki
                          blurRadius: 8, // Ýaýramagy
                          offset: const Offset(0, 4), // Aşak süýşmegi
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      // Dropdown açylanda menýunyň dizaýny
                      dropdownColor:
                          Theme.of(context)
                              .colorScheme
                              .primaryContainer, // Açylýan listiň fon reňki
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ), // Ikon üýtgetmek
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontFamily: "Bricolage",
                      ),

                      decoration: InputDecoration(
                        labelText: 'Korobka',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),

                        // Gyranyň tegelek we reňkli bolmagy
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

                      value: selectedGearbox,
                      // Menýunyň içindäki elementleriň dizaýny
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
                        _buildDropdownItem(
                          'hybrid',
                          'Gibrid',
                          Icons.electric_car,
                        ),
                      ],
                      onChanged: (val) => setState(() => selectedGearbox = val),
                    ),
                  ),
                ),

                const SizedBox(width: 10), // Aradaky boşluk
                // Ikinji Dropdown
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(
                            context,
                          ).colorScheme.primaryContainer, // Içki reňki
                      borderRadius: BorderRadius.circular(12), // Burçlary
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.1,
                          ), // Kölegäniň reňki
                          blurRadius: 8, // Ýaýramagy
                          offset: const Offset(0, 4), // Aşak süýşmegi
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      // Dropdown açylanda menýunyň dizaýny
                      dropdownColor:
                          Theme.of(context)
                              .colorScheme
                              .primaryContainer, // Açylýan listiň fon reňki
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ), // Ikon üýtgetmek
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                        fontFamily: 'Bricolage',
                      ),

                      decoration: InputDecoration(
                        labelText: 'Ýangyç',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),

                        // Gyranyň tegelek we reňkli bolmagy
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

                      value: selectedFuel,
                      // Menýunyň içindäki elementleriň dizaýny
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
                        _buildFuelItem(
                          'electric',
                          'Elektrik',
                          Icons.bolt,
                          Colors.blue,
                        ),
                        _buildFuelItem(
                          'hybrid',
                          'Gibrid',
                          Icons.eco,
                          Colors.green,
                        ),
                      ],
                      onChanged: (val) => setState(() => selectedFuel = val),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

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
                    builder: (_) => CategoryListPage(queryName: 'ulaglar'),
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
            TextArea(descCtr: descCtr),
            const SizedBox(height: 16),

            /// Suratlar bölümi
            _buildImagePicker(theme),

            const SizedBox(height: 24),

            /// Saklamak düwmesi
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
                child: const Text(
                  'ULAGY GOŞ',
                  style: TextStyle(
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
                itemBuilder:
                    (context, index) => Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_imageFileList[index].path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 8,
                          child: GestureDetector(
                            onTap:
                                () => setState(
                                  () => _imageFileList.removeAt(index),
                                ),
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
                    ),
              ),
            ),
        ],
      ),
    );
  }

  // API-e maglumat ibermek
  void _postedData() async {
    // 1. Базовая валидация (добавьте проверку на null для обязательных полей)
    if (titleCtr.text.isEmpty ||
        priceCtr.text.isEmpty ||
        selectedYear == null ||
        selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Haýyş edýän maglumatlary dolduruň!"),
        ),
      );
      return;
    }

    // 2. Подготовка данных с учетом типов (String -> Int)
    // В логе было "13 km", сервер может ждать просто число 13
    int? mileage = int.tryParse(
      mileageCtr.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    int? price = int.tryParse(priceCtr.text.replaceAll(RegExp(r'[^0-9]'), ''));

    Map<String, dynamic> dataMap = {
      'name': titleCtr.text,
      'phone': phoneCtr.text,
      'author': author,
      'description': descCtr.text,
      'price': price ?? 0,
      'year': int.tryParse(selectedYear!) ?? 2020,
      'color': selectedColor,
      'engine_volume': engineCtr.text,
      'mileage': mileage ?? 0,
      'gearbox': selectedGearbox,
      'fuel_type': selectedFuel,
      'category':
          selectedCategories.isNotEmpty ? selectedCategories[0].id : null,
      'address': selectedAddresses.isNotEmpty ? selectedAddresses[0].id : null,
      'current_addr':
          selectedAddresses.isNotEmpty ? selectedAddresses[0].id : null,
    };

    // Удаляем null значения, чтобы не путать сервер
    dataMap.removeWhere((key, value) => value == null);

    FormData formData = FormData.fromMap(dataMap);

    // 3. Добавление файлов
    if (_imageFileList.isNotEmpty) {
      // Главное фото (img)
      formData.files.add(
        MapEntry('img', await MultipartFile.fromFile(_imageFileList[0].path)),
      );

      // Список всех фото (images)
      // ВАЖНО: Проверьте, не ожидает ли сервер ключ 'images[]' для массива
      for (var file in _imageFileList) {
        formData.files.add(
          MapEntry('images', await MultipartFile.fromFile(file.path)),
        );
      }
    }

    try {
      // Добавьте заголовки, если сервер требует авторизацию
      Response response = await Dio().post(
        '$baseUrl/car/create/',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $author", // Если author — это токен
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ulag üstünlikli goşuldy!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (e is DioException) {
        // КРИТИЧЕСКИ ВАЖНО: посмотрите этот лог в консоли
        log("ОШИБКА СЕРВЕРА: ${e.response?.data}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка: ${e.response?.data.toString()}")),
        );
      }
      log("Error: $e");
    }
  }
}
