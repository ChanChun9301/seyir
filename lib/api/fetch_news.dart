import 'dart:convert';
import 'package:seyir/utils/constants.dart';
import 'package:http/http.dart' as http;
import '/utils/models.dart';

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

Future<NewsPage> getNewsApi(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/news-list/$id'));
  if (response.statusCode == 200) {
    return NewsPage.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Maglumat yok');
  }
}
