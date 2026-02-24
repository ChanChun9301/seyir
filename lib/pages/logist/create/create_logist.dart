import 'dart:io';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:seyir/pages/create/address_list.dart';
import 'package:seyir/pages/create/category_list.dart';
import '../../../widgets/fields/text_field.dart';
import '../../../widgets/fields/phone_text_field.dart';
import '../../../widgets/fields/price_text_field.dart';
import '../../../widgets/fields/textArea.dart';
import '../../../utils/constants.dart';
import '../../../component/navbar.dart';
import '../../../utils/models.dart';

class CreateLog extends StatefulWidget {
  const CreateLog({super.key});

  @override
  _CreateLogState createState() => _CreateLogState();
}

class _CreateLogState extends State<CreateLog> {
  DateTime selectedDate = DateTime.now();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _imageFileList = [];
  final String defaultImagePath = 'assets/no-image.jpg';

  List<SaylananCategory> selectedCategories = [];
  List<SaylananSalgy> selectedAddresses = [];

  TextEditingController titleCtr = TextEditingController();
  TextEditingController descCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();
  TextEditingController whereCtr = TextEditingController();
  TextEditingController nirdenCtr = TextEditingController();
  TextEditingController priceCtr = TextEditingController();

  String author = '';
  bool selectedVip = false;
  bool selectedBring = false;
  bool _validate = false;
  bool selectedIsClient = true;

  @override
  void initState() {
    super.initState();
    final _appToken = Hive.box('apptoken');
    author = _appToken.get('phone') ?? '';
    log('Author phone: $author');
  }

  Future<String> _copyAssetToTemp(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${(await getTemporaryDirectory()).path}/no-image.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  void selectDateFunc(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void selectedImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage(
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 600,
    );
    if (selectedImages != null && selectedImages.isNotEmpty) {
      _imageFileList.addAll(selectedImages);
      setState(() {});
    }
  }

  void deletImage(int index) {
    _imageFileList.removeAt(index);
    setState(() {});
  }

  void _saveLogist() async {
    // 1. Meýdançalaryň tekstini arassalamak we barlamak
    final name = titleCtr.text.trim();
    final price = priceCtr.text.trim();
    final nirden = nirdenCtr.text.trim();
    final where = whereCtr.text.trim();
    final phone = phoneCtr.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    ); // Diňe sanlary galdyrýar

    // 2. Logiki barlag (Validation)
    String? errorMessage;

    if (name.isEmpty)
      errorMessage = "Adyny ýazyň!";
    else if (nirden.isEmpty)
      errorMessage = "Ugradylýan ýeri ýazyň!";
    else if (where.isEmpty)
      errorMessage = "Barýan ýeri ýazyň!";
    else if (price.isEmpty)
      errorMessage = "Bahany ýazyň!";
    else if (phone.length < 8)
      errorMessage = "Telefon belgisini dogry ýazyň!";
    else if (selectedCategories.isEmpty)
      errorMessage = "Kategoriýa saýlaň!";
    else if (selectedAddresses.isEmpty)
      errorMessage = "Salgyny saýlaň!";

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
      return;
    }

    // 3. Surat bar bolsa ulanmak, ýok bolsa default goýmak
    if (_imageFileList.isEmpty) {
      String tempFilePath = await _copyAssetToTemp(defaultImagePath);
      _imageFileList.add(XFile(tempFilePath));
    }

    // 4. FormData taýýarlamak
    try {
      // Bahany san görnüşine geçirmek (Eger serwer san garaşýan bolsa)
      final cleanedPrice =
          double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

      FormData formData = FormData.fromMap({
        'name': name,
        // Serwer köplenç 'category' üçin san ýa-da ID-leriň sanawyny garaşýar
        'category': selectedCategories.first.id,
        'author': author,
        'where': where,
        'nirden': nirden,
        'last_date': selectedDate.toIso8601String().substring(0, 10),
        'address': selectedAddresses.first.id,
        'phone': phone, // +993-syz diňe 8 sany
        'img': await MultipartFile.fromFile(
          _imageFileList[0].path,
          filename: 'main_img.jpg',
        ),
        'text': descCtr.text.trim(),
        'price': cleanedPrice,
        'vip': selectedVip,
      });

      // Köp surat bar bolsa goşmak
      for (int i = 0; i < _imageFileList.length; i++) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              _imageFileList[i].path,
              filename: 'img_$i.jpg',
            ),
          ),
        );
      }

      // 5. Dio Request
      Dio dio = Dio();
      // Progress indicator görkezmek üçin loading dialog goşup bilersiňiz

      Response response = await dio.post(
        '$baseUrl/logistika/create/',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Maglumat üstünlikli ýatda saklandy'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/added_list',
          (route) => false,
        );
      }
    } catch (e) {
      log("Ýalňyşlyk ýüze çykdy: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Serwerde ýalňyşlyk döredi!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const NavBar(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          title: const Text(
            'Logistikas goşmak',
            style: const TextStyle(
              fontFamily: "Bricolage",
              letterSpacing: 2,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
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
          backgroundColor: theme.colorScheme.primary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: h / 56.27, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldCustom(ctr: titleCtr, text: 'Ady', validate: _validate),
            SizedBox(height: h / 84.4),
            Row(
              children: [
                Expanded(
                  child: PhoneTextFieldCustom(
                    ctr: phoneCtr,
                    validate: _validate,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: PriceTextFieldCustom(
                    ctr: priceCtr,
                    validate: _validate,
                  ),
                ),
              ],
            ),
            SizedBox(height: h / 84.4),
            TextFieldCustom(ctr: whereCtr, text: 'Nirä', validate: _validate),
            SizedBox(height: h / 84.4),
            TextFieldCustom(
              ctr: nirdenCtr,
              text: 'Nirden',
              validate: _validate,
            ),
            SizedBox(height: h / 84.4),
            TextArea(descCtr: descCtr),
            SizedBox(height: h / 84.4),

            // Дата
            InkWell(
              onTap: () => selectDateFunc(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(99, 99, 99, 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Icon(
                      Icons.date_range_outlined,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 14,
                        fontFamily: 'Bricolage',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: h / 84.4),

            // Переключатель Ulag / Müşderi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBringSwitch(theme),
                SizedBox(width: 10),

                _buildClientSwitch(theme),
              ],
            ),
            SizedBox(height: h / 84.4),

            // Выбор адреса
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

            // Загрузка изображений
            _buildImagePicker(theme),

            const SizedBox(height: 24),

            // Кнопка сохранить
            Container(
              width: w,
              height: 75,
              padding: EdgeInsets.only(top: height(context) / 84.4, bottom: 12),
              child: ElevatedButton(
                onPressed: _saveLogist,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
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

  Widget _buildBringSwitch(ThemeData theme) {
    return SizedBox(
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1,
            child: Switch(
              value: selectedBring,
              onChanged: (bool val) => setState(() => selectedBring = val),
              activeColor: theme.colorScheme.primary,
              inactiveThumbColor: Colors.blueGrey.shade600,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Alyp gitmeli\t / \tGetirmeli',
            style: TextStyle(
              color: theme.colorScheme.onSecondary,
              fontFamily: 'Bricolage',
              fontSize: 12,
            ),
          ),
        ],
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
              queryName: 'logistika',
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

  Widget _buildClientSwitch(ThemeData theme) {
    return SizedBox(
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1,
            child: Switch(
              value: selectedIsClient,
              onChanged: (bool val) => setState(() => selectedIsClient = val),
              activeColor: theme.colorScheme.primary,
              inactiveThumbColor: Colors.blueGrey.shade600,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Ulag\t / \tMüşderi',
            style: TextStyle(
              color: theme.colorScheme.onSecondary,
              fontFamily: 'Bricolage',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipGroup(List items, Function(int) onRemove) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Wrap(
        spacing: 8, // Chip-leriň arasyndaky boşluk
        runSpacing: 8, // Setirleriň arasyndaky boşluk
        children:
            items.map((sub) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Chip(
                  elevation: 0,
                  padding: const EdgeInsets.all(4), // <--- Şuny ulanmaly
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                  label: Text(
                    sub.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  deleteIcon: Icon(
                    Icons.cancel,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.7),
                  ),
                  onDeleted: () => onRemove(sub.id),
                ),
              );
            }).toList(),
      ),
    );
  }
}
