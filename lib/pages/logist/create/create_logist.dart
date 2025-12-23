import 'dart:io';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:seyir/main.dart';
import '../../../widgets/fields/text_field.dart';
import '../../../widgets/fields/phone_text_field.dart';
import '../../../widgets/fields/price_text_field.dart';
import '../../../widgets/fields/textArea.dart';
import '../../../widgets/text.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialogs.dart';
import '../../../component/navbar.dart';
import '../../../utils/models.dart';
import 'logistaddress.dart';
import 'logistcategory.dart';

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
    if (_imageFileList.isEmpty) {
      String tempFilePath = await _copyAssetToTemp(defaultImagePath);
      _imageFileList.add(XFile(tempFilePath));
    }

    FormData formData = FormData.fromMap({
      'name': titleCtr.text,
      'category': selectedCategories.map((e) => e.id.toString()).toList(),
      'author': author.substring(3),
      'where': whereCtr.text,
      'nirden': nirdenCtr.text,
      'last_date': selectedDate.toIso8601String().substring(0, 10),
      'address': selectedAddresses.map((e) => e.id.toString()).toList(),
      'phone': phoneCtr.text.substring(3),
      'img': await MultipartFile.fromFile(_imageFileList[0].path),
      'text': descCtr.text,
      'price': priceCtr.text,
      'vip': selectedVip,
      'images': [
        for (final image in _imageFileList)
          await MultipartFile.fromFile(image.path, filename: image.name),
      ],
    });

    Dio dio = Dio();
    try {
      Response response = await dio.post(
        '$baseUrl/logistika/create/',
        data: formData,
      );
      log(response.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Maglumat üstünlikli ýatda saklandy'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        title: const Text('Maglumat goşmak'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
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
                height: 35,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    const Icon(Icons.date_range_outlined, size: 14),
                    const SizedBox(width: 5),
                    Text("${selectedDate.toLocal()}".split(' ')[0]),
                  ],
                ),
              ),
            ),
            SizedBox(height: h / 84.4),

            // Переключатель Ulag / Müşderi
            Row(
              children: [
                Switch(
                  value: selectedBring,
                  onChanged: (val) => setState(() => selectedBring = val),
                ),
                const SizedBox(width: 5),
                const Text('Ulag / Müşderi'),
              ],
            ),
            SizedBox(height: h / 84.4),

            // Выбор адресов
            InkWell(
              onTap: () async {
                final result = await Navigator.push<List<SaylananSalgy>>(
                  context,
                  MaterialPageRoute(builder: (_) => LogistAddressPage()),
                );
                if (result != null) {
                  setState(() => selectedAddresses = result);
                }
              },
              child: Container(
                height: 40,
                width: w,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(99, 99, 99, 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Text(
                    'Salgyny saýla',
                    style: TextStyle(
                      fontFamily: "Bricolage",
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ),
            if (selectedAddresses.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children:
                    selectedAddresses.map((sub) {
                      return Chip(
                        avatar: Icon(
                          Icons.close,
                          size: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        label: Text(
                          sub.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        onDeleted: () {
                          setState(
                            () => selectedAddresses.removeWhere(
                              (item) => item.id == sub.id,
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),
            SizedBox(height: h / 84.4),

            // Выбор категорий
            InkWell(
              onTap: () async {
                final result = await Navigator.push<List<SaylananCategory>>(
                  context,
                  MaterialPageRoute(builder: (_) => LogistCategoryPage()),
                );
                if (result != null) {
                  setState(() => selectedCategories = result);
                }
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(99, 99, 99, 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Text(
                    'Kategoriýa',
                    style: TextStyle(
                      fontFamily: "Bricolage",
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ),
            if (selectedCategories.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children:
                    selectedCategories.map((sub) {
                      return Chip(
                        avatar: Icon(
                          Icons.close,
                          size: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        label: Text(
                          sub.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        onDeleted: () {
                          setState(
                            () => selectedCategories.removeWhere(
                              (item) => item.id == sub.id,
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),
            SizedBox(height: h / 84.4),

            // Загрузка изображений
            Container(
              width: double.infinity,
              height: _imageFileList.length > 3 ? 450 : 250,
              padding: const EdgeInsets.all(5),
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_imageFileList.length} sany surat'),
                      IconButton(
                        icon: const Icon(CupertinoIcons.camera_circle_fill),
                        onPressed: selectedImages,
                      ),
                    ],
                  ),
                  Expanded(
                    child: GridView.builder(
                      itemCount: _imageFileList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                      itemBuilder: (context, index) {
                        return Stack(
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
                                  borderRadius: BorderRadius.circular(50),
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Кнопка сохранить
            Container(
              width: w,
              height: 75,
              padding: EdgeInsets.only(top: height(context) / 84.4, bottom: 12),
              child: ElevatedButton(
                onPressed: _saveLogist,
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
    );
  }
}
