// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:seyir/pages/logist/logistaddress.dart';
import 'package:seyir/pages/logist/logistcategory.dart';
import '../../widgets/fields/price_text_field.dart';
import 'dart:developer';
import '../../utils/dialogs.dart';
import '../../utils/constants.dart';
import '../../widgets/text.dart';
import '../../widgets/fields/phone_text_field.dart';
import '../../widgets/fields/textArea.dart';
import '../../widgets/fields/text_field.dart';
import 'dart:io';
import '../../utils/getData.dart';
import '../../component/navbar.dart';
import '../../utils/models.dart';

class CreateLog extends StatefulWidget {
  CreateLog({Key? key}) : super(key: key);

  @override
  _CreateLogState createState() => _CreateLogState();
}

class _CreateLogState extends State<CreateLog>
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
    final List<XFile> selectedImages = await _picker.pickMultiImage(
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

  List<SaylananCategory> selectedCategories = [];
  List<SaylananSalgy> selectedAddresses = [];

  Future<List<SaylananCategory>> loadSelectedCategories() async {
    final box = Hive.box<SaylananCategory>('selected_categories');
    return box.values.toList();
  }

  Future<List<SaylananSalgy>> loadSelectedAddresses() async {
    final box = Hive.box<SaylananSalgy>('selected_addresses');
    return box.values.toList();
  }

  TextEditingController titleCtr = TextEditingController();
  TextEditingController descCtr = TextEditingController();
  TextEditingController imgCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();
  TextEditingController whereCtr = TextEditingController();
  TextEditingController nirdenCtr = TextEditingController();
  TextEditingController priceCtr = TextEditingController();

  String author = '';

  bool showSpinner = false;
  final _appToken = Hive.box('apptoken');
  @override
  void initState() {
    setState(() {
      author = _appToken.get('token');
    });
    super.initState();
    // loadSelectedCategories().then((loaded) {
    //   setState(() {
    //     selectedCategories = loaded;
    //   });
    // });

    // loadSelectedAddresses().then((loaded) {
    //   setState(() {
    //     selectedAddresses = loaded;
    //   });
    // });
  }

  selectDateFunc(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      helpText: 'Ahyrky senäni saýla',
      confirmText: 'Tassykla',
      cancelText: 'Yza çyk',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(),
            datePickerTheme: DatePickerTheme.of(context).copyWith(
              backgroundColor: Colors.grey.shade200,
              shadowColor: Colors.grey,
              confirmButtonStyle: ButtonStyle(
                textStyle: MaterialStateProperty.resolveWith<TextStyle?>((
                  Set<MaterialState> states,
                ) {
                  return const TextStyle(
                    color: Color(0xff296e48),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  );
                }),
              ),
              headerForegroundColor: Color(0xff296e48),
              yearForegroundColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                return Color(0xff296e48);
              }),
              dividerColor: Colors.grey,
              yearOverlayColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.green.withOpacity(
                    0.5,
                  ); // Color for selected year
                }
                return Colors.green.shade200; // Default overlay color
              }),
              rangePickerHeaderForegroundColor: Color(0xff296e48),
              cancelButtonStyle: ButtonStyle(
                textStyle: MaterialStateProperty.resolveWith<TextStyle?>((
                  Set<MaterialState> states,
                ) {
                  return const TextStyle(
                    color: Color(0xff296e48),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  );
                }),
              ),
              // colo
              headerHelpStyle: const TextStyle(
                color: Color(0xff296e48),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              headerHeadlineStyle: const TextStyle(
                color: Color(0xff296e48),
                fontSize: 14,
              ),
              yearStyle: const TextStyle(
                color: Color(0xff296e48),
                fontSize: 14,
              ),
              dayStyle: const TextStyle(color: Color(0xff296e48), fontSize: 14),
              dayForegroundColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white; // Color for selected day
                }
                return Color(0xff296e48); // Default color for days
              }),
              rangePickerHeaderHelpStyle: const TextStyle(
                color: Color(0xff296e48),
                fontSize: 16,
              ),
              weekdayStyle: const TextStyle(
                color: Color(0xff296e48),
                fontSize: 16,
              ),
              surfaceTintColor: Colors.grey.shade200,
              dayOverlayColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.green.withOpacity(
                    0.5,
                  ); // Overlay for selected day
                }
                return Colors
                    .green
                    .shade200; // Default overlay color for unselected days
              }),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                focusColor: Color(0xff296e48),
                fillColor: Colors.green[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color(0xff296e48), width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color(0xff296e48), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Color(0xff296e48)),
              ),
              todayForegroundColor: MaterialStatePropertyAll(Colors.white),
              yearBackgroundColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.green.withOpacity(
                    0.3,
                  ); // Background for selected year
                }
                return Colors
                    .transparent; // Default background for unselected years
              }),
              headerBackgroundColor: Colors.grey.shade200,
              // dayOverlayColor: MaterialStatePropertyAll(Color(0xff296e48)),
            ),
          ),
          child: child!,
        );
      },
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    setState(() {
      selectedDate = picked!;
    });
  }

  int index = 0;
  int count = 5;
  List<Map<String, dynamic>> items = [];

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        title: const Text(
          'Maglumat goşmak',
          style: TextStyle(
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      // extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: h / 56.27),
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: h / 84.4),
              TextFieldCustom(ctr: titleCtr, text: 'Ady', validate: _validate),
              SizedBox(height: h / 84.4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PhoneTextFieldCustom(ctr: phoneCtr, validate: _validate),
                  PriceTextFieldCustom(ctr: priceCtr, validate: _validate),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 35,
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
                child: InkWell(
                  onTap:
                      () => setState(() {
                        selectDateFunc(context);
                      }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.date_range_outlined,
                        color: Colors.black,
                        size: 14,
                      ),
                      const SmallText(text: '\tHaçana çenli:\t'),
                      const SizedBox(width: 10),
                      SmallText(
                        text: "${selectedDate.toLocal()}".split(' ')[0],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: h / 84.4),
              SizedBox(
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1,
                      child: Switch(
                        value: selectedBring,
                        onChanged: (bool val) {
                          setState(() {
                            selectedBring = val;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveThumbColor: Colors.blueGrey.shade600,
                        inactiveTrackColor: Colors.grey.shade400,
                        // splashRadius: 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Alyp gitmelimi\t / \tGetirmelimi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Bricolage',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: h / 84.4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      Navigator.push<List<SaylananSalgy>>(
                        context,
                        MaterialPageRoute(builder: (_) => LogistAddressPage()),
                      );
                    },
                    child: Container(
                      height: 30,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(99, 99, 99, 0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Salgyny saýla',
                            style: TextStyle(
                              fontFamily: 'Bricolage',
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (selectedSubaddresses.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        children:
                            selectedSubaddresses.map((sub) {
                              return Chip(
                                label: Text(
                                  sub.name,
                                  style: TextStyle(
                                    fontFamily: 'Bricolage',
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                deleteIcon: Icon(
                                  Icons.close_outlined,
                                  color: Colors.red,
                                ),
                                onDeleted: () {
                                  setState(() {
                                    selectedSubaddresses.removeWhere(
                                      (item) => item.id == sub.id,
                                    );
                                  });
                                },
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                              );
                            }).toList(),
                      ),
                    ),
                ],
              ),
              SizedBox(height: h / 84.4),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      Navigator.push<List<SaylananCategory>>(
                        context,
                        MaterialPageRoute(builder: (_) => LogistCategoryPage()),
                      );
                    },
                    child: Container(
                      height: 30,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(99, 99, 99, 0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kategoriýa',
                            style: TextStyle(
                              fontFamily: 'Bricolage',
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (selectedSubcategories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        children:
                            selectedSubcategories.map((sub) {
                              return Chip(
                                label: Text(
                                  sub.name,
                                  style: TextStyle(
                                    fontFamily: 'Bricolage',
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                deleteIcon: Icon(
                                  Icons.close_outlined,
                                  color: Colors.red,
                                ),
                                onDeleted: () {
                                  setState(() {
                                    selectedSubcategories.removeWhere(
                                      (item) => item.id == sub.id,
                                    );
                                  });
                                },
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                              );
                            }).toList(),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),
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
                    const SizedBox(height: 5),
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
                                      child:
                                          (_imageFileList.isNotEmpty)
                                              ? Image.file(
                                                File(
                                                  _imageFileList[index].path,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : Container(),
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
                padding: EdgeInsets.only(top: h / 84.4, bottom: 12),
                width: w,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    if (priceCtr.text == '' ||
                        phoneCtr.text == '' ||
                        titleCtr.text == '' ||
                        descCtr.text == ''
                    // ||
                    // selectedAddress == null ||
                    // selectedCategory == null
                    ) {
                      setState(() {
                        showPostDialog(context);
                      });
                    } else {
                      _postedLogist();
                      Navigator.pushNamed(context, '/added_list');
                    }
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

  void _postedLogist() async {
    if (_imageFileList.isEmpty) {
      String tempFilePath = await _copyAssetToTemp(defaultImagePath);
      _imageFileList.add(XFile(tempFilePath));
    }
    FormData formData = FormData.fromMap({
      'name': titleCtr.text,
      // 'category': selectedCategory!.id.toString(),
      'author': author,
      'where': whereCtr.text,
      'nirden': nirdenCtr.text,
      'last_date': selectedDate.toString().substring(0, 10),
      'bring': selectedBring,
      // 'address': selectedAddress!.id.toString(),
      'phone': phoneCtr.text.substring(3),
      'img': await MultipartFile.fromFile(_imageFileList[0].path),
      'text': descCtr.text,
      'price': priceCtr.text,
      'vip': selectedVip,
      'images': [
        for (final image in _imageFileList.where((image) => image != null))
          await MultipartFile.fromFile(image!.path, filename: image.name),
      ],
    });
    Dio dio = Dio();
    try {
      Response response = await dio.post(
        '$baseUrl/logist-list/',
        data: formData,
      );
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(snackBarFunc);
      });
      log(response.toString());
    } catch (e) {
      log(e.toString());
    }
  }
}
