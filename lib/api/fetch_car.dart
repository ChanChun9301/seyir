import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<PageModel>> getData(int page, Map<dynamic, dynamic> filter) async {
  // Базовые параметры
  Map<String, String> queryParams = {
    'checked': 'True',
    'page': page.toString(),
  };

  // Добавляем фильтры, преобразуем значения в строки
  filter.forEach((key, value) {
    queryParams[key] = value.toString();
  });

  // Формируем Uri с параметрами
  final uri = Uri.parse(
    '$baseUrl/carmain-list/',
  ).replace(queryParameters: queryParams);

  final response = await http.get(uri);
  try{
    if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    List results = data['results'];
    return results.map((e) => PageModel.fromJson(e)).toList();
  } else {
    return [];
  }
  }catch (e) {
     return [];
  }
 

  
}

Future<List<PageModel>> getSearchData(String text) async {
  final response = await http.get(
    Uri.parse('$baseUrl/carmain-list/?search=$text&checked=true'),
  );
  Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
  List results = data['results'];
  if (response.statusCode == 200) {
    return results.map((e) => PageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}

Future<CarDetailModel> getCarDetailApi(String id) async {
  final response = await http.get(Uri.parse('$baseUrl/car-list/$id'));
  if (response.statusCode == 200) {
    return CarDetailModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load detail data');
  }
}

Future<List<CategoryPage>> fetchCategories() async {
  final response = await http.get(Uri.parse('$baseUrl/carcategory-list/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => CategoryPage.fromJson(e)).toList();
  } else {
    throw Exception('Kategoriýalar ýükläp bolmady');
  }
}

Future<List<PageModel>> getAddedData(String token, int page) async {
  final response = await http.get(
    Uri.parse('$baseUrl/car-added-list/?author=$token&page=$page'),
  );
  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    List results = data['results'];
    return results.map((e) => PageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}

Future<List<AddressPage>> fetchAddress() async {
  final response = await http.get(Uri.parse('$baseUrl/address-list/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => AddressPage.fromJson(e)).toList();
  } else {
    throw Exception('Kategoriýalar ýükläp bolmady');
  }
}
