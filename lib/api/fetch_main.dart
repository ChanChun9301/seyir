import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<PageModel>> getData(
  String urlName,
  int page,
  Map<dynamic, dynamic> filter,
) async {
  Map<String, String> queryParams = {
    'checked': 'True',
    'page': page.toString(),
  };

  filter.forEach((key, value) {
    queryParams[key] = value.toString();
  });

  final uri = Uri.parse(
    '$baseUrl/${urlName}main-list/',
  ).replace(queryParameters: queryParams);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    List results = data['results'];
    return results.map((e) => PageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}

Future<List<CategoryPage>> fetchCategories(String query) async {
  final response = await http.get(Uri.parse('$baseUrl/${query}category-list/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => CategoryPage.fromJson(e)).toList();
  } else {
    throw Exception('Kategoriýalar ýükläp bolmady');
  }
}

Future<List<PageModel>> getAddedData(
  String token,
  String query,
  int page,
) async {
  final response = await http.get(
    Uri.parse('$baseUrl/$query-added-list/?author=$token&page=$page'),
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

Future<DetailModel> getMainDetail(String query, String id) async {
  final response = await http.get(Uri.parse('$baseUrl/$query-list/$id'));
  try {
    if (response.statusCode == 200) {
      return DetailModel.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load detail data');
    }
  } catch (e) {
    throw Exception('Failed to load detail data');
  }
}

Future<List<PageModel>> getSearchData(String text, String model) async {
  final response = await http.get(
    Uri.parse('$baseUrl/$model-list/?search=$text&checked=true'),
  );
  Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
  List results = data['results'];
  if (response.statusCode == 200) {
    return results.map((e) => PageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}
