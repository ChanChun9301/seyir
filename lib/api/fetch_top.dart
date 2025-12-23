import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:seyir/utils/constants.dart';
import 'package:seyir/utils/models.dart';
import 'package:http/http.dart' as http;

Future<List<PageModel>> fetchTopListApi({int pageNum = 1}) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/top-products/?checked=True&page=$pageNum'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      final List results = data['results'] ?? [];
      return results.map((e) => PageModel.fromJson(e)).toList();
    }
  } catch (e) {
    debugPrint('Failed to load data: $e');
  }
  return [];
}

Future<TopDetailModel> getTopDetailApi(String id) async {
  final response = await http.get(Uri.parse('$baseUrl/top-products/$id'));
  if (response.statusCode == 200) {
    return TopDetailModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  } else {
    throw Exception('Failed to load album');
  }
}
