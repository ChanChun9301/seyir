import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<LogistDetailModel> getLogistDetailApi(String id) async {
  final response = await http.get(Uri.parse('$baseUrl/logistika/$id'));
  if (response.statusCode == 200) {
    return LogistDetailModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load album');
  }
}

Future<List<AddressPage>> fetchAddress() async {
  final response = await http.get(Uri.parse('$baseUrl/addresses/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => AddressPage.fromJson(e)).toList();
  } else {
    throw Exception('Kategoriýalar ýükläp bolmady');
  }
}

Future<List<LogistCategory>> fetchCategories() async {
  final response = await http.get(Uri.parse('$baseUrl/categories/logistika/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => LogistCategory.fromJson(e)).toList();
  } else {
    throw Exception('Kategoriýalar ýükläp bolmady');
  }
}

Future<List<LogistPageModel>> getData(
  int page,
  String client,
  Map<dynamic, dynamic> filter,
) async {
  Map<String, String> queryParams = {
    'checked': 'True',
    'page': page.toString(),
    'client': client,
  };
  filter.forEach((key, value) {
    queryParams[key] = value.toString();
  });

  // Формируем Uri с параметрами
  final uri = Uri.parse(
    '$baseUrl/logist-list/',
  ).replace(queryParameters: queryParams);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    List results = data['results'];
    return results.map((e) => LogistPageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}
