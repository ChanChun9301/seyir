import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<AddressPage>> fetchAddress() async {
  final response = await http.get(Uri.parse('$baseUrl/addresses/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => AddressPage.fromJson(e)).toList();
  } else {
    throw Exception('Kategoriýalar ýükläp bolmady');
  }
}

Future<List<CategoryPage>> fetchCategories(String endpoint) async {
  final response = await http.get(Uri.parse('$baseUrl/categories/$endpoint/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => CategoryPage.fromJson(e)).toList();
  } else {
    throw Exception('Kategoriýalar ýükläp bolmady');
  }
}


  Future<List<PageModel>> getData(String urlName, String filter,int page) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$urlName/?checked=True&page=$page$filter'),
    );

    if (response.statusCode == 200) {
      // Декодируем сразу в List, так как в JSON нет ключа 'results'
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      List results = data['results'] ?? [];

      return results.map((e) => PageModel.fromJson(e)).toList();
    } else {
      // Хорошей практикой будет вывести лог ошибки для отладки
      print("Ошибка запроса: ${response.statusCode}");
      return [];
    }
  }