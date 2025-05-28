// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:seyir/widgets/fields/price_text_field.dart';
import '../../utils/dialogs.dart';
import 'dart:developer';
import 'dart:io';
import '../../utils/constants.dart';
import '../../widgets/fields/phone_text_field.dart';
import '../../widgets/fields/textArea.dart';
import '../../widgets/fields/text_field.dart';
import '../../utils/getData.dart';
import '../../component/navbar.dart';
import '../../utils/models.dart';

class CreateProd extends StatefulWidget {
  final String? title;
  final String? query;
  const CreateProd({
    Key? key,
    required this.title,
    required this.query,
  }) : super(key: key);

  @override
  _CreateProdState createState() => _CreateProdState();
}

class _CreateProdState extends State<CreateProd>
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
        imageQuality: 50, maxWidth: 800, maxHeight: 600);

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

  String author = '';

  List<AddressPage> addresses = [];
  AddressPage? selectedAddress;
  List<CategoryPage> categories = [];
  CategoryPage? selectedCategory;

  // bool showSpinner = false;
  final _appToken = Hive.box('apptoken');
  @override
  void initState() {
    super.initState();
    setState(() {
      author = _appToken.get('token');
    });
    getAddress().then((addressList) {
      setState(() {
        addresses = addressList;
      });
    }).catchError((error) {
      debugPrint(error);
    });
    getDataCategory(widget.query!).then((categoryList) {
      setState(() {
        categories = categoryList;
      });
    }).catchError((error) {
      debugPrint(error);
    });
  }

  int index = 0;
  int count = 5;
  List<Map<String, dynamic>> items = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const NavBar(),
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              title: Text(
                '${widget.title} goşmak',
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2,
                    fontFamily: "Bricolage",
                    fontSize: 20,
                    color: Colors.white),
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
                      size: 20,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(height(context) / 56.13))),
            )),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: height(context) / 56.27),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height(context) / 84.4),
              TextFieldCustom(
                ctr: titleCtr,
                text: 'Ady',
                validate: _validate,
              ),
              SizedBox(height: height(context) / 84.4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PhoneTextFieldCustom(
                    ctr: phoneCtr,
                    validate: _validate,
                  ),
                  PriceTextFieldCustom(
                    ctr: priceCtr,
                    validate: _validate,
                  ),
                ],
              ),
              SizedBox(height: height(context) / 84.4),
              TextArea(descCtr: descCtr),
              SizedBox(height: height(context) / 84.4),
              Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(99, 99, 99, 0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: Offset(
                          0,
                          2,
                        ),
                      ),
                    ],
                  ),
                  // padding: EdgeInsets.only(left: h/56.27, right: 12),
                  child: DropdownButtonFormField<AddressPage>(
                    dropdownColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 10, right: 10),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 2, color: Colors.white38),
                          borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 2, color: Colors.green),
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      focusColor: Colors.white38,
                      fillColor: Theme.of(context).colorScheme.primaryContainer,
                      hintText: "Maglumatlary...",
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    icon: Icon(
                      Icons.expand_circle_down,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    hint: Text('Salgyny saýla',
                        style: TextStyle(
                            fontFamily: "Bricolage",
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary)),
                    value: selectedAddress,
                    onChanged: (AddressPage? newValue) {
                      setState(() {
                        selectedAddress = newValue;
                      });
                    },
                    items: addresses.map<DropdownMenuItem<AddressPage>>(
                        (AddressPage address) {
                      return DropdownMenuItem<AddressPage>(
                        value: address,
                        child: Text(address.title),
                      );
                    }).toList(),
                  )),
              SizedBox(height: height(context) / 84.4),
              Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(99, 99, 99, 0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: Offset(
                          0,
                          2,
                        ),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<CategoryPage>(
                    dropdownColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 10, right: 10),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 2, color: Colors.white38),
                          borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 2, color: Colors.green),
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      focusColor: Colors.white38,
                      fillColor: Theme.of(context).colorScheme.primaryContainer,
                      hintText: "Maglumatlary...",
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    icon: Icon(
                      Icons.expand_circle_down,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    hint: Text('Kategoriýany saýla',
                        style: TextStyle(
                            fontFamily: "Bricolage",
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary)),
                    value: selectedCategory,
                    onChanged: (CategoryPage? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                    items: categories.map<DropdownMenuItem<CategoryPage>>(
                        (CategoryPage category) {
                      return DropdownMenuItem<CategoryPage>(
                        value: category,
                        child: Text(category.title),
                      );
                    }).toList(),
                  )),
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
                      offset: Offset(
                        0,
                        2,
                      ),
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
                              fontSize: 10),
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
                                  crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return _imageFileList.isNotEmpty
                                ? Stack(children: [
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
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: IconButton(
                                            onPressed: () {
                                              deletImage(index);
                                            },
                                            icon: Icon(
                                              CupertinoIcons.delete,
                                              size: 10,
                                              color: Colors.red[600],
                                            )),
                                      ),
                                    ),
                                  ])
                                : const Center();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.only(top: height(context) / 84.4, bottom: 12),
                width: width(context),
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    if (priceCtr.text == '' ||
                        phoneCtr.text == '' ||
                        titleCtr.text == '' ||
                        descCtr.text == '' ||
                        selectedAddress == null ||
                        selectedCategory == null) {
                      setState(() {
                        showPostDialog(context);
                      });
                    } else {
                      _postedData(widget.query!);
                      Navigator.pushNamed(context, '/added_list');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
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
        )));
  }

  void _postedData(String name) async {
    if (_imageFileList.isEmpty) {
      String tempFilePath = await _copyAssetToTemp(defaultImagePath);
      _imageFileList.add(XFile(tempFilePath));
    }
    FormData formData = FormData.fromMap({
      'name': titleCtr.text,
      'phone': phoneCtr.text.substring(3),
      'author': author,
      'text': descCtr.text,
      'price': priceCtr.text,
      'address': selectedAddress!.id.toString(),
      'category': selectedCategory!.id.toString(),
      'img': await MultipartFile.fromFile(_imageFileList[0].path),
      'images': [
        for (final image in _imageFileList.where((image) => image != null))
          await MultipartFile.fromFile(image!.path, filename: image.name),
      ]
    });
    Dio dio = Dio();
    log(formData.fields.toString());
    log(formData.files.toString());
    try {
      Response response =
          await dio.post('$baseUrl/$name-list/', data: formData);
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(snackBarFunc);
      });
      log(response.toString());
    } catch (e) {
      log(e.toString());
    }
  }
}
