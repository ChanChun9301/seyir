// ignore_for_file: file_names
import 'dart:convert';
import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:seyir/utils/constants.dart';
import 'package:http/http.dart' as http;
import '/utils/models.dart';

Future<DetailModel> getDetailDataApi(String query, String id) async {
  final response = await http.get(Uri.parse('$baseUrl/$query/$id'));
  if (response.statusCode == 200) {
    log(response.toString());
    return DetailModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load detail data');
  }
}

Future<http.Response> deleteData(String query, String id) async {
  final http.Response response = await http.delete(
    Uri.parse('$baseUrl/$query-list/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 204) {
    return response;
  } else {
    throw Exception('Pozulmady');
  }
}

Future<LogistDetailModel> getLogistDetailDataApi(String id) async {
  final response = await http.get(Uri.parse('$baseUrl/logistika/$id'));
  if (response.statusCode == 200) {
    return LogistDetailModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load album');
  }
}

Future<List<LogistPageModel>> getLogistData(String filter) async {
  final response = await http.get(
    Uri.parse('$baseUrl/logistmain-list/?checked=True$filter'),
  );
  Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
  List results = data['results'];
  if (response.statusCode == 200) {
    return results.map((e) => LogistPageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}

Future<DetailModel> getTopDetailDataApi(String id) async {
  final response = await http.get(Uri.parse('$baseUrl/top-products/$id'));
  if (response.statusCode == 200) {
    return DetailModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load album');
  }
}

Future<DetailModel> getDataApi(String urlName, String id) async {
  final response = await http.get(Uri.parse('$baseUrl/$urlName-list/$id'));
  if (response.statusCode == 200) {
    return DetailModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load album');
  }
}

Future<List<AddressPage>> getAddress() async {
  final response = await http.get(
    Uri.parse('$baseUrl/addresses/?checked=true'),
  );
  List data = jsonDecode(utf8.decode(response.bodyBytes));
  if (response.statusCode == 200) {
    return data.map((e) => AddressPage.fromJson(e)).toList();
  } else {
    return [];
  }
}

Future<List<CategoryPage>> getDataCategory(String urlName) async {
  final response = await http.get(
    Uri.parse('$baseUrl/categories/${urlName}/?checked=true'),
  );
  List data = jsonDecode(utf8.decode(response.bodyBytes));
  if (response.statusCode == 200) {
    return data.map((e) => CategoryPage.fromJson(e)).toList();
  } else {
    return [];
  }
}

Future<List<NewsPage>> getDataNews() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/news-list/?checked=true'),
    );
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    List results = data['results'];
    if (response.statusCode == 200) {
      return results.map((e) => NewsPage.fromJson(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}

Future<List<PageModel>> getFilterData(
  String pageName,
  String url,
  String name,
) async {
  final response = await http.get(
    Uri.parse('$baseUrl/$pageName-by-$url-list/?search=$name&checked=true'),
  );
  Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
  List results = data['results'];
  if (response.statusCode == 200) {
    return results.map((e) => PageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}

Future<List<LogistPageModel>> getFilterLogistData(
  String url,
  String name,
) async {
  final response = await http.get(
    Uri.parse('$baseUrl/logist-by-$url-list/?search=$name&checked=true'),
  );
  Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
  List results = data['results'];
  if (response.statusCode == 200) {
    return results.map((e) => LogistPageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}

Future<bool> getTokenApi(String token) async {
  final appToken = Hive.box('apptoken');
  var token = appToken.get('token');

  final response = await http.get(
    Uri.parse('$baseUrl/user-check/?author=$token'),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['token'] == true) {
      return data['token'] as bool;
    }
    return false;
  } else {
    return false;
  }
}
