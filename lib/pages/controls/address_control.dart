import 'dart:convert';
import 'package:get/get.dart';
import '/utils/constants.dart';
import '/utils/models.dart';
import 'package:http/http.dart' as http;

class AddressControl extends GetxController {
  final _addressItems = <AddressPage>[].obs;

  List<AddressPage> get addressItems => _addressItems.toList();

  void fetchAddressItems() async {
    final response = await http.get(Uri.parse('$baseUrl/addresses/'));
    final data = json.decode(response.body) as List<dynamic>;

    _addressItems.value = data
        .map((item) => AddressPage.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
