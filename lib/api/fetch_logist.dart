import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<LogistDetailModel> getLogistDetailApi(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/logistika/$id'));
  if (response.statusCode == 200) {
    return LogistDetailModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load album');
  }
}

Future<List<LogistPageModel>> getData(String filter, int page) async {
  final baseUri = Uri.parse(baseUrl);

  // Собираем параметры. Если filter уже содержит '&', парсим его аккуратно.
  Map<String, String> queryParams = {
    'checked': 'True',
    'page': page.toString(),
    'is_client': 'False',
  };

  final url = Uri(
    scheme: baseUri.scheme,
    host: baseUri.host,
    port: baseUri.port,
    path: '/logistika/',
    queryParameters: queryParams,
  );

  // Добавляем ручной фильтр, если он передан как строка
  final finalUrl = filter.isNotEmpty ? Uri.parse('$url$filter') : url;

  try {
    final response = await http.get(finalUrl);

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));

      // ПРОВЕРКА: Если пришел список (как в твоем примере)
      if (decodedData is List) {
        return decodedData.map((e) => LogistPageModel.fromJson(e)).toList();
      }
      // Если пришел объект с ключом 'results' (пагинация Django)
      else if (decodedData is Map && decodedData.containsKey('results')) {
        List results = decodedData['results'];
        return results.map((e) => LogistPageModel.fromJson(e)).toList();
      }

      return [];
    } else {
      print('Server Error: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error during request: $e');
    return [];
  }
}




  Future<List<LogistPageModel>> getAddedLogistData(String gettoken,int page) async {
    // isLoading = true;
    final response = await http.get(
      Uri.parse('$baseUrl/logistika/added/?author=$gettoken&page=$page'),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List results = data['results'];
      return results.map((e) => LogistPageModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }