// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:seyir/pages/lists/address_list.dart';
import 'package:seyir/pages/lists/category_list.dart';
import 'package:seyir/pages/logist/create/logistaddress.dart';
import 'package:seyir/pages/logist/create/logistcategory.dart';
import 'package:seyir/api/fetch_logist.dart';
import '../../../widgets/fields/price_text_field.dart';
import 'dart:developer';
import '../../../utils/constants.dart';
import '../../../widgets/text.dart';
import '../../../widgets/fields/phone_text_field.dart';
import '../../../widgets/fields/textArea.dart';
import '../../../widgets/fields/text_field.dart';
import 'dart:io';
import '../../../component/navbar.dart';
import '../../../utils/models.dart';

class UpdateLogist extends StatefulWidget {
  final int? id;
  final bool isEditing;

  const UpdateLogist({super.key, this.id, this.isEditing = false});

  @override
  _UpdateLogistState createState() => _UpdateLogistState();
}

class _UpdateLogistState extends State<UpdateLogist>
    with SingleTickerProviderStateMixin {
  late Future<LogistDetailModel> futureData;

  DateTime selectedDate = now;
  final ImagePicker _picker = ImagePicker();
  final List<dynamic> _imageFileList = [];
  final String defaultImagePath = 'assets/no-image.jpg';
  List<String> deletedImageIds = []; // Pozuljak suratlaryň ID-leri
  bool isMainImageDeleted = false;

  String suratText = '';
  bool _validate = false;
  bool selectedVip = false;
  bool selectedBring = false;
  bool selectedIsClient = true;
  bool showSpinner = false;
  bool isDataLoaded = false;

  // Контроллеры
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();
  TextEditingController whereCtr = TextEditingController();
  TextEditingController nirdenCtr = TextEditingController();
  TextEditingController priceCtr = TextEditingController();

  String author = '';
  final _appToken = Hive.box('apptoken');

  List<SaylananCategory> selectedCategories = [];
  List<SaylananSalgy> selectedAddresses = [];

  @override
  void initState() {
    super.initState();
    author = _appToken.get('token', defaultValue: '');
    futureData = getLogistDetailApi(widget.id!);
    if (widget.isEditing && widget.id != null) {
      _loadData(); // API-dan maglumat alyp doldurjak funksiýamyz
    }
  }

  Future<void> _loadData() async {
    try {
      // API-dan maglumaty garaşyp alýarys
      LogistDetailModel data = await getLogistDetailApi(widget.id!);

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

  void _fillFields(LogistDetailModel data) {
    if (isDataLoaded) return;

    titleCtr.text = data.title;
    descCtr.text = data.desc;
    phoneCtr.text = data.phone;
    whereCtr.text = data.where ?? '';
    nirdenCtr.text = data.nirden ?? '';
    priceCtr.text = data.price.toString();
    selectedBring = data.isBring;
    selectedDate = DateTime.parse(data.lastDate);
    titleCtr.text = data.title;
    descCtr.text = data.desc;
    phoneCtr.text = data.phone;
    whereCtr.text = data.where ?? '';
    nirdenCtr.text = data.nirden ?? '';
    priceCtr.text = data.price.toString();
    selectedBring = data.isBring;
    selectedDate = DateTime.parse(data.lastDate);

    // Kategoriýany doldurmak
    if (data.categoryName.isNotEmpty) {
      selectedCategories = [
        SaylananCategory(
          id: int.tryParse(data.category_id) ?? 0,
          name: data.categoryName,
        ),
      ];
    }

    // Salgyny doldurmak
    if (data.addressName.isNotEmpty) {
      selectedAddresses = [
        SaylananSalgy(
          id: int.tryParse(data.address_id) ?? 0,
          name: data.addressName,
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

  void selectedImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage(
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 600,
    );

    if (selectedImages.isNotEmpty) {
      setState(() {
        _imageFileList.addAll(selectedImages);
      });
    }
  }

  Future<void> selectDateFunc(BuildContext context) async {
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
                textStyle: WidgetStateProperty.resolveWith<TextStyle?>((
                  Set<WidgetState> states,
                ) {
                  return const TextStyle(
                    color: Color(0xff296e48),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  );
                }),
              ),
              headerForegroundColor: Color(0xff296e48),
              yearForegroundColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                return Color(0xff296e48);
              }),
              dividerColor: Colors.grey,
              yearOverlayColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.green.withOpacity(
                    0.5,
                  ); // Color for selected year
                }
                return Colors.green.shade200; // Default overlay color
              }),
              rangePickerHeaderForegroundColor: Color(0xff296e48),
              cancelButtonStyle: ButtonStyle(
                textStyle: WidgetStateProperty.resolveWith<TextStyle?>((
                  Set<WidgetState> states,
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
              dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
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
              dayOverlayColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
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
              todayForegroundColor: WidgetStatePropertyAll(Colors.white),
              yearBackgroundColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
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
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Maglumat redaktirlemek' : 'Maglumat goşmak',
          style: const TextStyle(
            letterSpacing: 2,
            fontFamily: "Bricolage",
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
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
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: h / 56.27),
          child: Column(
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

              // Дата окончания
              _buildDateSelector(theme, context),
              SizedBox(height: h / 84.4),

              // Переключатель "Привезти/Забрать"
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
              SizedBox(height: h / 84.4),

              // Кнопка сохранения
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

  Widget _buildDateSelector(ThemeData theme, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 35,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
        onTap: () => selectDateFunc(context),
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
            SmallText(text: "${selectedDate.toLocal()}".split(' ')[0]),
          ],
        ),
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

  bool _validateForm() {
    String errorMessage = "";

    // 1. Esasy tekst meýdançalaryny barlamak
    if (titleCtr.text.trim().isEmpty) {
      errorMessage = "Sözbaşy giriziň!";
    } else if (priceCtr.text.trim().isEmpty) {
      errorMessage = "Bahany giriziň!";
    } else if (phoneCtr.text.trim().length < 8) {
      errorMessage = "Telefon belgisini dogry giriziň!";
    } else if (descCtr.text.trim().isEmpty) {
      errorMessage = "Düşündiriş ýazyň!";
    }
    // 2. Kategoriýa we Salgy barlagy
    else if (selectedCategories.isEmpty) {
      errorMessage = "Kategoriýa saýlaň!";
    } else if (selectedAddresses.isEmpty) {
      errorMessage = "Salgyny saýlaň!";
    }
    // 3. Logistika üçin mahsus barlaglar (Nirden/Nire)
    else if (whereCtr.text.trim().isEmpty || nirdenCtr.text.trim().isEmpty) {
      errorMessage = "Ugraljak we baryljak ýeri giriziň!";
    }

    // Netije
    if (errorMessage.isNotEmpty) {
      setState(() {
        _validate = true; // TextFormField-laryň errorText-ini janlandyrmak üçin
      });

      // Ulanyja Dialog ýa-da SnackBar arkaly anyk näme ýalňyşdygyny aýtmak
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Eger öňki Dialogyňyz gerek bolsa, ony hem çagyryp bilersiňiz
      // showPostDialog(context);

      return false;
    }

    return true;
  }

  Future<void> _postedData() async {
    // 1. Validasiýa barlagy
    if (!_validateForm()) return;

    setState(() => showSpinner = true);

    try {
      // 2. Esasy maglumatlar kartasy (Map)
      Map<String, dynamic> dataMap = {
        'name': titleCtr.text,
        'category': selectedCategories.first.id,
        'where': whereCtr.text,
        'nirden': nirdenCtr.text,
        'last_date': selectedDate.toString().substring(0, 10),
        'bring': selectedBring,
        'is_client': selectedIsClient,
        'address': selectedAddresses.first.id,
        'phone': phoneCtr.text.replaceAll(RegExp(r'[^0-9]'), ''), // Diňe sanlar
        'text': descCtr.text,
        'price': priceCtr.text,
        'vip': selectedVip,
        // Eger öňki kodlaryňyzda bar bolsa, bularam goşup bilersiňiz:
        'delete_images': deletedImageIds.join(','),
        'is_main_image_deleted': isMainImageDeleted ? "true" : "false",
      };

      // Multipart üçin FormData taýýarlamak
      FormData formData = FormData.fromMap(dataMap);

      // 3. Suratlary işlemek (Dynamic Handling)
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

      // 4. URL we Metod kesgitlemek
      String url =
          '$baseUrl/logistika/update/${widget.id}/'; // create URL-iňizi ýazyň

      // Django/DRF Multipart PATCH soraglaryny POST arkaly kabul edip bilýär
      Options options = Options(
        method: 'PATCH',
        headers: {"Authorization": "Bearer $author"}, // Token bar bolsa
      );

      // 5. Sorag ibermek
      Response response = await Dio().request(
        url,
        data: formData,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Täzelendi!')));
        Navigator.pop(
          context,
          true,
        ); // Sahypany ýap we yzyna 'true' ugrat (Refresh üçin)
      }
    } on DioException catch (e) {
      log('Dio Error: ${e.response?.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ýalňyşlyk: ${e.response?.data ?? e.message}')),
      );
    } finally {
      setState(() => showSpinner = false);
    }
  }
}
