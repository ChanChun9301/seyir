import 'dart:convert';
import 'package:get/get.dart';
import '/utils/constants.dart';
import '/utils/models.dart';
import 'package:http/http.dart' as http;

class CarouselControl extends GetxController {
  final _carouselItems = <CarouselPage>[].obs;

  List<CarouselPage> get carouselItems => _carouselItems.toList();

  void fetchCarouselItems() async {
    final response = await http.get(Uri.parse('$baseUrl/carousel/'));
    final data = json.decode(response.body) as List<dynamic>;
    // print(data);
    if (data.isNotEmpty) {
      _carouselItems.value = (data)
          .map((item) => CarouselPage.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      // _carouselItems
    }
  }
}
