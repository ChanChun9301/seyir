import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import './constants.dart';

class PageModel {
  String id;
  String title;
  String desc;
  String img;
  String phone;
  String price;
  DateTime created;
  String addressName;
  String categoryName;
  bool checked;

  PageModel({
    required this.id,
    required this.title,
    required this.phone,
    required this.price,
    required this.checked,
    required this.desc,
    required this.img,
    required this.created,
    required this.categoryName,
    required this.addressName,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) => PageModel(
    id: json["pk"].toString(),
    title: json["name"] ?? '',
    phone: json["phone"].toString(),
    price: json["price"] ?? '',
    desc: json["text"] ?? '',
    img: json["img"] ?? json["thumbnail"] ?? '',
    checked: json["checked"] ?? false,
    created: DateTime.tryParse(json['created']) ?? DateTime.now(),
    addressName: json["address_name"] ?? '',
    categoryName: json["category_name"] ?? '',
  );
  String get createdString => DateFormat('yyyy-MM-dd').format(created);
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "phone": phone,
    "price": price,
    "desc": desc,
    "img": img,
    "checked": checked,
    "address_name": addressName,
    "category_name": categoryName,
    "created": created,
  };
}

class TopPageModel {
  String id;
  String title;
  String desc;
  String img;
  String phone;
  String price;
  DateTime created;
  String addressName;
  bool checked;

  TopPageModel({
    required this.id,
    required this.title,
    required this.phone,
    required this.price,
    required this.checked,
    required this.desc,
    required this.img,
    required this.created,
    required this.addressName,
  });

  factory TopPageModel.fromJson(Map<String, dynamic> json) => TopPageModel(
    id: json["pk"].toString(),
    title: json["name"] = json["name"] ?? '',
    phone: json["phone"] = json["phone"].toString(),
    price: json["price"] = json["price"] ?? '',
    desc: json["text"] = json["text"] ?? '',
    img: json["img"] = json["img"] ?? '',
    checked: json["checked"] = json["checked"] ?? '',
    created:
        json["created"] = DateTime.tryParse(json['created']) ?? DateTime.now(),
    addressName: json["address_name"] = json["address_name"] ?? '',
    // categoryName: json["category_name"] = json["category_name"] ?? '',
  );
  String get createdString => DateFormat('yyyy-MM-dd').format(created);
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "phone": phone,
    "price": price,
    "desc": desc,
    "img": img,
    "checked": checked,
    "address_name": addressName,
    // "category_name": categoryName,
    "created": created,
  };
}

class LogistPageModel {
  String id;
  String title;
  String desc;
  String img;
  String categoryName;
  String phone;
  String where;
  String nirden;
  bool checked;
  String lastDate;
  bool isBring;
  bool isVip;
  String price;
  DateTime created;

  LogistPageModel({
    required this.id,
    required this.title,
    required this.phone,
    required this.price,
    required this.where,
    required this.nirden,
    required this.lastDate,
    required this.isBring,
    required this.isVip,
    required this.desc,
    required this.img,
    required this.created,
    required this.categoryName,
    required this.checked,
    // required this.addressName,
  });

  factory LogistPageModel.fromJson(Map<String, dynamic> json) =>
      LogistPageModel(
        id: json["pk"].toString(),
        title: json["name"] = json["name"] ?? '',
        phone: json["phone"] = json["phone"].toString(),
        price: json["price"] = json["price"] ?? '',
        where: json["where"] = json["where"] ?? '',
        nirden: json["nirden"] = json["nirden"] ?? '',
        lastDate: json["last_date"] = json["last_date"] ?? '',
        isBring: json["bring"] = json["bring"] ?? '',
        isVip: json["vip"] = json["vip"] ?? '',
        desc: json["text"] = json["text"] ?? '',
        img: json["img"] = json["img"] ?? '',
        checked: json["checked"] = json["checked"] ?? false,
        created:
            json["created"] =
                DateTime.tryParse(json['created']) ?? DateTime.now(),
        categoryName: json["category_name"] = json["category_name"] ?? '',
      );
  String get createdString => DateFormat('yyyy-MM-dd').format(created);
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "phone": phone,
    "where": where,
    "nirden": nirden,
    "last_date": lastDate,
    "bring": isBring,
    "vip": isVip,
    "price": price,
    "desc": desc,
    "img": img,
    "checked": checked,
    // "address_name": addressName,
    "category_name": categoryName,
    "created": created,
  };
}

class LogistDetailModel {
  String id;
  String title;
  String desc;
  String where;
  String nirden;
  String lastDate;
  bool isBring;
  bool isVip;
  String img;
  List<String> images = [];
  String phone;
  String price;
  DateTime created;
  String address;
  String category;

  // ✅ Täze meýdanlar
  double? latitude;
  double? longitude;

  LogistDetailModel({
    required this.id,
    required this.title,
    required this.phone,
    required this.price,
    required this.where,
    required this.nirden,
    required this.lastDate,
    required this.isBring,
    required this.isVip,
    required this.desc,
    required this.img,
    required this.images,
    required this.created,
    required this.address,
    required this.category,
    this.latitude,
    this.longitude,
  });

  factory LogistDetailModel.fromJson(Map<String, dynamic> json) =>
      LogistDetailModel(
        id: json["pk"].toString(),
        title: json["name"] ?? '',
        phone: json["phone"].toString(),
        price: json["price"] ?? '',
        where: json["where"] ?? '',
        nirden: json["nirden"] ?? '',
        lastDate: json["last_date"] ?? '',
        isBring: json["bring"] ?? false,
        isVip: json["vip"] ?? false,
        desc: json["text"] ?? '',
        img: json["img"] ?? '',
        images:
            json["images"] != null
                ? List<String>.from(json["images"].map((x) => x))
                : [],
        created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
        address: json["address"] ?? '',
        category: json["category"] ?? '',

        // ✅ Latitude / Longitude üýtgedilýär
        latitude:
            json["latitude"] != null
                ? double.tryParse(json["latitude"].toString())
                : null,
        longitude:
            json["longitude"] != null
                ? double.tryParse(json["longitude"].toString())
                : null,
      );

  String get createdString => DateFormat('yyyy-MM-dd').format(created);

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "phone": phone,
    "price": price,
    "where": where,
    "nirden": nirden,
    "last_date": lastDate,
    "bring": isBring,
    "vip": isVip,
    "desc": desc,
    "img": img,
    "images": images,
    "category": category,
    "address": address,
    "created": created.toIso8601String(),

    // ✅ Latitude / Longitude serialize edilýär
    "latitude": latitude,
    "longitude": longitude,
  };
}

class DetailModel {
  String id;
  String title;
  String desc;
  String img;
  List<String> images;
  String phone;
  String price;
  DateTime created;
  String address;
  String category;

  DetailModel({
    required this.id,
    required this.title,
    required this.phone,
    required this.price,
    required this.desc,
    required this.img,
    required this.images,
    required this.created,
    required this.address,
    required this.category,
  });

  factory DetailModel.fromJson(Map<String, dynamic> json) => DetailModel(
    id: json["pk"].toString(),
    title: json["name"] ?? '',
    phone: json["phone"].toString(),
    price: json["price"] ?? '',
    desc: removeHtmlTags(json["text"] ?? ''),
    img: json["img"] ?? '',
    images: (json["images"] as List).map((e) => e["url"].toString()).toList(),
    created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
    address: json["address"] ?? '',
    category: json["category"] ?? '',
  );

  String get createdString => DateFormat('yyyy-MM-dd').format(created);

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "phone": phone,
    "price": price,
    "desc": desc,
    "img": img,
    "images": images,
    "category": category,
    "address": address,
    "created": created.toIso8601String(),
  };
}

class PostDetailModel {
  String id;
  String title;
  String desc;
  File img;
  File images;
  String phone;
  String price;
  DateTime created;
  String address;
  String category;

  PostDetailModel({
    required this.id,
    required this.title,
    required this.phone,
    required this.price,
    required this.desc,
    required this.img,
    required this.images,
    required this.created,
    required this.address,
    required this.category,
  });

  factory PostDetailModel.fromJson(Map<String, dynamic> json) =>
      PostDetailModel(
        id: json["pk"].toString(),
        title: json["name"] = json["name"] ?? '',
        phone: json["phone"] = json["phone"].toString(),
        price: json["price"] = json["price"] ?? '',
        desc: json["text"] = json["text"] ?? '',
        img: json["img"] = json["img"] ?? '',
        images: json["images"] = json["images"] ?? '',
        created:
            json["created"] =
                DateTime.tryParse(json['created']) ?? DateTime.now(),
        address: json["address"] = json["address"] ?? '',
        category: json["category"] = json["category"] ?? '',
      );
  String get createdString => DateFormat('yyyy-MM-dd').format(created);
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "phone": phone,
    "price": price,
    "desc": desc,
    "img": img,
    "images": images,
    "category": category,
    "address": address,
    "created": created,
  };
}

class CategoryPage {
  String id;
  String title;

  CategoryPage({required this.id, required this.title});

  factory CategoryPage.fromJson(Map<String, dynamic> json) =>
      CategoryPage(id: json["pk"].toString(), title: json["name"]);
  Map<String, dynamic> toJson() => {"id": id, "title": title};
}

class SaylananCategory {
  final int id;
  final String name;

  SaylananCategory({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory SaylananCategory.fromJson(Map<String, dynamic> json) =>
      SaylananCategory(id: json['id'], name: json['name']);
}

class SaylananSalgy {
  final int id;
  final String name;

  SaylananSalgy({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory SaylananSalgy.fromJson(Map<String, dynamic> json) =>
      SaylananSalgy(id: json['id'], name: json['name']);
}

class LogistCategory {
  final int pk;
  final String name;
  final List<LogistSubCategory> subcategories;

  LogistCategory({
    required this.pk,
    required this.name,
    required this.subcategories,
  });

  factory LogistCategory.fromJson(Map<String, dynamic> json) {
    return LogistCategory(
      pk: json['pk'],
      name: json['name'],
      subcategories:
          (json['subcategories'] as List)
              .map((e) => LogistSubCategory.fromJson(e))
              .toList(),
    );
  }
}

class LogistSubCategory {
  final int pk;
  final String name;

  LogistSubCategory({required this.pk, required this.name});

  factory LogistSubCategory.fromJson(Map<String, dynamic> json) {
    return LogistSubCategory(pk: json['pk'], name: json['name']);
  }
}

class AddressPage {
  String id;
  String title;
  List<AddressPage> subaddresses;

  AddressPage({
    required this.id,
    required this.title,
    this.subaddresses = const [],
  });

  factory AddressPage.fromJson(Map<String, dynamic> json) => AddressPage(
    id: json["pk"].toString(),
    title: json["name"],
    subaddresses:
        json["subaddresses"] != null
            ? List<AddressPage>.from(
              json["subaddresses"].map((x) => AddressPage.fromJson(x)),
            )
            : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "subaddresses": List<dynamic>.from(subaddresses.map((x) => x.toJson())),
  };
}

class TokenPage {
  String title;

  TokenPage({required this.title});

  factory TokenPage.fromJson(Map<String, dynamic> json) =>
      TokenPage(title: json["name"]);

  Map<String, dynamic> toJson() => {"title": title};
}

class NewsPage {
  String id;
  String title;
  String desc;
  String img;
  DateTime created;
  String author;
  String category;

  NewsPage({
    required this.id,
    required this.title,
    required this.desc,
    required this.img,
    required this.created,
    required this.author,
    required this.category,
  });

  factory NewsPage.fromJson(Map<String, dynamic> json) => NewsPage(
    id: json["pk"].toString(),
    title: json["name"],
    desc: json["text"],
    img: json["img"],
    created: DateTime.tryParse(json['created']) ?? DateTime.now(),
    author: json["author"],
    category: json["category"],
  );
  String get createdString => DateFormat('yyyy-MM-dd').format(created);
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "desc": desc,
    "img": img,
    "category": category,
    "author": author,
    "created": created,
  };
}

List<CarouselPage> carouselFromJson(String str) => List<CarouselPage>.from(
  json.decode(str).map((x) => CarouselPage.fromJson(x)),
);

class CarouselPage {
  final int pk;
  final String name;
  final String img;

  CarouselPage({required this.pk, required this.name, required this.img});

  factory CarouselPage.fromJson(Map<String, dynamic> json) =>
      CarouselPage(pk: json["pk"], name: json["name"], img: json["img"]);

  Map<String, dynamic> toJson() => {"pk": pk, "name": name, "img": img};
}
