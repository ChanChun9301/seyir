import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../../utils/models.dart';

class CategoryControl extends GetxController {
  final _categoryItems = <CategoryPage>[].obs;
  final String urlName = '';

  List<CategoryPage> get addressItems => _categoryItems.toList();

  void fetchAddressItems() async {
    final response =
        await http.get(Uri.parse('$baseUrl/${urlName}category-list/'));
    final data = json.decode(response.body);

    _categoryItems.value = data
        .map((item) => CategoryPage.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
