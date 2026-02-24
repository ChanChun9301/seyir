import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// getData indi 'endpoint' kabul edýär (meselen: 'carmain-list' ýa-da 'spares')
Future<List<PageModel>> getData(int page, String filterString) async {
  // filterString eýýäm '&key=value' görnüşinde gelýär
  // Şonuň üçin ony göni URL-e birikdirip bileris
  final String url = '$baseUrl/spares/?checked=True&page=$page$filterString';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List results = data['results'];
      return results.map((e) => PageModel.fromJson(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    print("API Error: $e");
    return [];
  }
}

// Meňzeş usulda Search funksiýasy
Future<List<PageModel>> getSearchData(String endpoint, String text) async {
  final response = await http.get(
    Uri.parse('$baseUrl/$endpoint/?search=$text&checked=true'),
  );
  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    List results = data['results'];
    return results.map((e) => PageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}

Future<SpareDetailModel> getSpareDetailApi(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/spares/$id/'));

  if (response.statusCode == 200) {
    return SpareDetailModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  } else {
    print("API Error: ${response.statusCode}");
    throw Exception('Maglumaty ýükläp bolmady: Spares');
  }
}

Future<List<SparePageModel>> getAddedData(String token, int page) async {
  final response = await http.get(
    Uri.parse('$baseUrl/spares/added/?author=$token&page=$page'),
  );
  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    List results = data['results'];
    return results.map((e) => SparePageModel.fromJson(e)).toList();
  } else {
    return [];
  }
}
