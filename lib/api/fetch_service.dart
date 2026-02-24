import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<ServicePageModel>> getData(int page, Map<dynamic, dynamic> filter) async {
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
    '$baseUrl/hyzmatlar/',
  ).replace(queryParameters: queryParams);

  final response = await http.get(uri);
  try {
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List results = data['results'];
      return results.map((e) => ServicePageModel.fromJson(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}

Future<List<ServicePageModel>> getSearchData(String text) async {
  final response = await http.get(
    Uri.parse('$baseUrl/hyzmatlar/?search=$text&checked=true'),
  );
  Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
  List results = data['results'];
  if (response.statusCode == 200) {
    return results.map((e) => ServicePageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}

Future<DetailModel> getServiceDetailApi(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/hyzmatlar/$id'));
  if (response.statusCode == 200) {
    return DetailModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load detail data');
  }
}

Future<List<CategoryPage>> fetchCategories(String queryName) async {
  final response = await http.get(Uri.parse('$baseUrl/categories/$queryName/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => CategoryPage.fromJson(e)).toList();
  } else {
    throw Exception('Kategoriýalar ýükläp bolmady');
  }
}

Future<List<ServicePageModel>> getAddedData(String token, int page) async {
  final response = await http.get(
    Uri.parse('$baseUrl/hyzmatlar/added/?author=$token&page=$page'),
  );
  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    List results = data['results'];
    return results.map((e) => ServicePageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}
