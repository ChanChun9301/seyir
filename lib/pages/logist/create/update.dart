// ignore_for_file: file_names, library_private_types_in_public_api, camel_case_types
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:seyir/pages/logist/create/logistaddress.dart';
import 'package:seyir/pages/logist/create/logistcategory.dart';
import '../../../widgets/fields/price_text_field.dart';
import 'dart:developer';
import '../../../utils/dialogs.dart';
import '../../../utils/constants.dart';
import '../../../widgets/text.dart';
import '../../../widgets/fields/phone_text_field.dart';
import '../../../widgets/fields/textArea.dart';
import '../../../widgets/fields/text_field.dart';
import 'dart:io';
import '../../../utils/getData.dart';
import '../../../component/navbar.dart';
import '../../../utils/models.dart';

class CreateUpdateLog extends StatefulWidget {
  final LogistDetailModel? logistData;
  final bool isEditing;

  const CreateUpdateLog({super.key, this.logistData, this.isEditing = false});

  @override
  _CreateUpdateLogState createState() => _CreateUpdateLogState();
}

class _CreateUpdateLogState extends State<CreateUpdateLog>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = now;
  final ImagePicker _picker = ImagePicker();
  final List<dynamic> _imageFileList = [];
  final String defaultImagePath = 'assets/no-image.jpg';
  String suratText = '';
  bool _validate = false;
  bool selectedVip = false;
  bool selectedBring = false;
  bool showSpinner = false;

  // Контроллеры
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();
  TextEditingController whereCtr = TextEditingController();
  TextEditingController nirdenCtr = TextEditingController();
  TextEditingController priceCtr = TextEditingController();

  String author = '';
  final _appToken = Hive.box('apptoken');

  List<SaylananCategory> selectedSubcategories = [];
  List<SaylananSalgy> selectedSubaddresses = [];

  @override
  void initState() {
    super.initState();
    author = _appToken.get('token');

    // Если редактируем существующую запись, заполняем данные
    if (widget.isEditing && widget.logistData != null) {
      final data = widget.logistData!;
      titleCtr.text = data.title;
      descCtr.text = data.desc;
      phoneCtr.text = data.phone;
      whereCtr.text = data.where ?? '';
      nirdenCtr.text = data.nirden ?? '';
      priceCtr.text = data.price.toString();
      selectedBring = data.isBring;
      selectedDate = DateTime.parse(data.lastDate);

      // Загружаем изображения если они есть
      if (data.images.isNotEmpty) {
        // Здесь нужно реализовать загрузку изображений из сети
        // _loadNetworkImages(data.images);
      }

      // Загружаем категории и адреса
      // _loadCategoriesAndAddresses(data);
    }
  }

  Future<String> _copyAssetToTemp(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${(await getTemporaryDirectory()).path}/no-image.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
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

  void deletImage(int index) {
    setState(() {
      _imageFileList.removeAt(index);
    });
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
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: const NavBar(),
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
      backgroundColor: theme.colorScheme.surface,
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
              _buildBringSwitch(theme),
              SizedBox(height: h / 84.4),

              // Выбор адреса
              _buildAddressSelector(theme),
              SizedBox(height: h / 84.4),

              // Выбор категории
              _buildCategorySelector(theme),
              SizedBox(height: h / 84.4),

              // Загрузка изображений
              _buildImageUploader(theme, h),
              SizedBox(height: h / 84.4),

              // Кнопка сохранения
              _buildSaveButton(theme, w, h),
            ],
          ),
        ),
      ),
    );
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
            'Alyp gitmelimi\t / \tGetirmelimi',
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

  Widget _buildAddressSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            final result = await Navigator.push<List<SaylananSalgy>>(
              context,
              MaterialPageRoute(builder: (_) => LogistAddressPage()),
            );
            if (result != null) {
              setState(() => selectedSubaddresses = result);
            }
          },
          child: Container(
            height: 30,
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Salgyny saýla',
                  style: TextStyle(
                    fontFamily: 'Bricolage',
                    fontSize: 10,
                    color: theme.colorScheme.secondary,
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
                  selectedSubaddresses
                      .map(
                        (sub) => Chip(
                          label: Text(sub.name),
                          deleteIcon: const Icon(
                            Icons.close_outlined,
                            color: Colors.red,
                          ),
                          onDeleted:
                              () => setState(
                                () => selectedSubaddresses.removeWhere(
                                  (item) => item.id == sub.id,
                                ),
                              ),
                        ),
                      )
                      .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            final result = await Navigator.push<List<SaylananCategory>>(
              context,
              MaterialPageRoute(builder: (_) => LogistCategoryPage()),
            );
            if (result != null) {
              setState(() => selectedSubcategories = result);
            }
          },
          child: Container(
            height: 30,
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kategoriýa',
                  style: TextStyle(
                    fontFamily: 'Bricolage',
                    fontSize: 10,
                    color: theme.colorScheme.secondary,
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
                  selectedSubcategories
                      .map(
                        (sub) => Chip(
                          label: Text(sub.name),
                          deleteIcon: const Icon(
                            Icons.close_outlined,
                            color: Colors.red,
                          ),
                          onDeleted:
                              () => setState(
                                () => selectedSubcategories.removeWhere(
                                  (item) => item.id == sub.id,
                                ),
                              ),
                        ),
                      )
                      .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildImageUploader(ThemeData theme, double h) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: _imageFileList.length > 3 ? 450 : 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontFamily: 'Bricolage',
                  fontSize: 10,
                ),
              ),
              IconButton(
                icon: Icon(
                  CupertinoIcons.camera_circle_fill,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                onPressed: () {
                  if (_imageFileList.length < 5) {
                    selectedImages();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Surat saýlamak limidi doly'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: GridView.builder(
              itemCount: _imageFileList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      child: Image.file(
                        File(_imageFileList[index].path),
                        fit: BoxFit.cover,
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
                          onPressed: () => deletImage(index),
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
    );
  }

  Widget _buildSaveButton(ThemeData theme, double w, double h) {
    return Container(
      padding: EdgeInsets.only(top: h / 84.4, bottom: 12),
      width: w,
      height: 75,
      child: ElevatedButton(
        onPressed: () async {
          if (_validateForm()) {
            setState(() => showSpinner = true);
            try {
              if (widget.isEditing) {
                await _updateLogist();
              } else {
                await _createLogist();
              }
              Navigator.pushNamed(context, '/added_list');
            } catch (e) {
              log('Error: $e');
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Ýalňyşlyk: $e')));
            } finally {
              setState(() => showSpinner = false);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        child:
            showSpinner
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  widget.isEditing
                      ? 'Üýtgetmeleri ýatda sakla'
                      : 'Maglumaty ýatda sakla',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: "Bricolage",
                    letterSpacing: 1,
                  ),
                ),
      ),
    );
  }

  bool _validateForm() {
    if (priceCtr.text.isEmpty ||
        phoneCtr.text.isEmpty ||
        titleCtr.text.isEmpty ||
        descCtr.text.isEmpty ||
        selectedSubaddresses.isEmpty ||
        selectedSubcategories.isEmpty) {
      setState(() {
        _validate = true;
        showPostDialog(context);
      });
      return false;
    }
    return true;
  }

  Future<void> _createLogist() async {
    if (_imageFileList.isEmpty) {
      String tempFilePath = await _copyAssetToTemp(defaultImagePath);
      _imageFileList.add(XFile(tempFilePath));
    }

    FormData formData = FormData.fromMap({
      'name': titleCtr.text,
      'category': selectedSubcategories.first.id.toString(),
      'author': author,
      'where': whereCtr.text,
      'nirden': nirdenCtr.text,
      'last_date': selectedDate.toString().substring(0, 10),
      'bring': selectedBring,
      'address': selectedSubaddresses.first.id.toString(),
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

    await _sendRequest('$baseUrl/logist-list/', formData);
  }

  Future<void> _updateLogist() async {
    if (widget.logistData == null) return;

    FormData formData = FormData.fromMap({
      'name': titleCtr.text,
      'category': selectedSubcategories.first.id.toString(),
      'where': whereCtr.text,
      'nirden': nirdenCtr.text,
      'last_date': selectedDate.toString().substring(0, 10),
      'bring': selectedBring,
      'address': selectedSubaddresses.first.id.toString(),
      'phone': phoneCtr.text.substring(3),
      'text': descCtr.text,
      'price': priceCtr.text,
      'vip': selectedVip,
      if (_imageFileList.isNotEmpty)
        'img': await MultipartFile.fromFile(_imageFileList[0].path),
      if (_imageFileList.length > 1)
        'images': [
          for (final image in _imageFileList.skip(1))
            await MultipartFile.fromFile(image.path, filename: image.name),
        ],
    });

    await _sendRequest(
      '$baseUrl/logist-list/${widget.logistData!.id}/',
      formData,
      isPut: true,
    );
  }

  Future<void> _sendRequest(
    String url,
    FormData formData, {
    bool isPut = false,
  }) async {
    Dio dio = Dio();
    try {
      Response response =
          isPut
              ? await dio.put(url, data: formData)
              : await dio.post(url, data: formData);

      log(response.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Üstünlikli!')));
    } on DioException catch (e) {
      log('Dio Error: ${e.response?.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ýalňyşlyk: ${e.response?.data ?? e.message}')),
      );
      rethrow;
    }
  }
}
