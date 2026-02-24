import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import './constants.dart';

// ========================= IMAGE MODEL =========================
class ImageModel {
  final int pk;
  final String url;

  ImageModel({required this.pk, required this.url});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      pk:
          (json['pk'] is int)
              ? json['pk']
              : int.tryParse(json['pk']?.toString() ?? '') ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'pk': pk, 'url': url};
}

// ========================= BASE PAGE MODEL =========================
class BasePageModel {
  String id;
  String title;
  String desc;
  String img;
  String phone;
  String price;
  DateTime created;
  bool checked;

  BasePageModel({
    required this.id,
    required this.title,
    required this.phone,
    required this.price,
    required this.desc,
    required this.img,
    required this.created,
    required this.checked,
  });

  String get createdString => DateFormat('yyyy-MM-dd').format(created);
}
// ========================= SPARE PAGE MODEL =========================

class SparePageModel extends BasePageModel {
  String addressName;
  String categoryName;

  String address_id;
  String category_id;

  String? partNumber; // Täze
  int? year; // Täze
  String condition; // Täze
  String compatibility; // Täze

  SparePageModel({
    required String id,
    required String title,
    required String phone,
    required String price,
    required bool checked,
    required String desc,
    required String img,
    required DateTime created,
    required this.categoryName,
    required this.addressName,
    required this.category_id,
    required this.address_id,
    this.partNumber,
    this.year,
    required this.condition,
    required this.compatibility,
  }) : super(
         id: id,
         title: title,
         phone: phone,
         price: price,
         desc: desc,
         img: img,
         created: created,
         checked: checked,
       );

  factory SparePageModel.fromJson(Map<String, dynamic> json) {
    // Django-dan gelýän 'condition' bahasyny türkmençä öwürmek
    String rawCondition = json["condition"]?.toString() ?? 'used';
    String translatedCondition;

    switch (rawCondition) {
      case 'new':
        translatedCondition = 'Täze';
        break;
      case 'refurbished':
        translatedCondition = 'Dikelden';
        break;
      default:
        translatedCondition = 'Ulanylan';
    }

    return SparePageModel(
      id: json["pk"].toString(),
      title: json["name"]?.toString() ?? '',
      phone: json["phone"]?.toString() ?? '',
      price: json["price"]?.toString() ?? '',
      desc: json["text"]?.toString() ?? '',
      img: json["img"] ?? json["thumbnail"] ?? '',
      checked: json["checked"] ?? false,
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      categoryName: json["category_name"]?.toString() ?? '',
      addressName: json["address_name"]?.toString() ?? '',
      category_id: json["category_id"]?.toString() ?? '',
      address_id: json["address__id"]?.toString() ?? '',
      compatibility: json["compatibility"]?.toString() ?? '',
      // Täze meýdanlar:
      partNumber: json["part_number"]?.toString(),
      year:
          json["year"] is int
              ? json["year"]
              : int.tryParse(json["year"]?.toString() ?? ''),
      condition: translatedCondition,
    );
  }

  @override
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
    "created": created.toIso8601String(),
    "part_number": partNumber,
    "year": year,
    "condition": condition,
  };
}

// ========================= PAGE MODEL =========================

class ServicePageModel {
  final String id;
  final String title;
  final String phone;
  final String price;
  final String desc;
  final bool checked;
  final String img;
  final String categoryName;
  final String addressName;
  final String category_id;
  final String address_id;
  final DateTime created;

  ServicePageModel({
    required this.id,
    required this.title,
    required this.phone,
    required this.price,
    required this.desc,
    required this.img,
    required this.categoryName,
    required this.checked,
    required this.category_id,
    required this.addressName,
    required this.address_id,
    required this.created,
  });

  factory ServicePageModel.fromJson(Map<String, dynamic> json) {
    return ServicePageModel(
      id: json["pk"].toString(),
      title: json["name"] ?? '',
      phone: json["phone"] ?? '',
      price: json["price"]?.toString() ?? '0',
      desc: json["text"] ?? '',
      img: json["img"] ?? '',
      checked: json["checked"] ?? '',
      categoryName: json["category_name"] ?? '',
      addressName: json["address_name"] ?? '',
      category_id: json["category_id"] ?? '',
      address_id: json["address_id"] ?? '',
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
    );
  }
}

class PageModel extends BasePageModel {
  String addressName;
  String categoryName;

  PageModel({
    required String id,
    required String title,
    required String phone,
    required String price,
    required bool checked,
    required String desc,
    required String img,
    required DateTime created,
    required this.categoryName,
    required this.addressName,
  }) : super(
         id: id,
         title: title,
         phone: phone,
         price: price,
         desc: desc,
         img: img,
         created: created,
         checked: checked,
       );

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json["pk"].toString(),
      title: json["name"]?.toString() ?? '',
      phone: json["phone"]?.toString() ?? '',
      price: json["price"]?.toString() ?? '',
      desc: json["text"]?.toString() ?? '',
      img: json["img"] ?? json["thumbnail"] ?? '',
      checked: json["checked"] ?? false,
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      categoryName: json["category_name"]?.toString() ?? '',
      addressName: json["address_name"]?.toString() ?? '',
    );
  }

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
    "created": created.toIso8601String(),
  };
}

// ========================= TOP PAGE MODEL =========================
class TopPageModel extends BasePageModel {
  String addressName;

  TopPageModel({
    required String id,
    required String title,
    required String phone,
    required String price,
    required bool checked,
    required String desc,
    required String img,
    required DateTime created,
    required this.addressName,
  }) : super(
         id: id,
         title: title,
         phone: phone,
         price: price,
         desc: desc,
         img: img,
         created: created,
         checked: checked,
       );

  factory TopPageModel.fromJson(Map<String, dynamic> json) {
    return TopPageModel(
      id: json["pk"].toString(),
      title: json["name"]?.toString() ?? '',
      phone: json["phone"]?.toString() ?? '',
      price: json["price"]?.toString() ?? '',
      desc: json["text"]?.toString() ?? '',
      img: json["img"]?.toString() ?? '',
      checked: json["checked"] ?? false,
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      addressName: json["address_name"]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "phone": phone,
    "price": price,
    "desc": desc,
    "img": img,
    "checked": checked,
    "address_name": addressName,
    "created": created.toIso8601String(),
  };
}

// ========================= LOGIST PAGE MODEL =========================

class LogistPageModel {
  String id;
  String title;
  String desc;
  String img;
  String categoryName;
  String addressName;
  String phone;
  String where;
  String nirden;
  String lastDate;
  bool isBring;
  bool isClient;
  bool checked;
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
    required this.isClient,
    required this.desc,
    required this.img,
    required this.created,
    required this.categoryName,
    required this.addressName,
    required this.checked,
  });

  factory LogistPageModel.fromJson(Map<String, dynamic> json) {
    return LogistPageModel(
      id: json["pk"].toString(),
      title: json["name"]?.toString() ?? '',
      phone: json["phone"]?.toString() ?? '',
      price: json["price"]?.toString() ?? '',
      where: json["where"]?.toString() ?? '',
      nirden: json["nirden"]?.toString() ?? '',
      lastDate: json["last_date"]?.toString() ?? '',
      isBring: json["bring"] ?? false,
      isClient: json["client"] ?? false,
      desc: json["text"]?.toString() ?? '',
      img: json["img"]?.toString() ?? '',
      checked: json["checked"] ?? false,
      created: DateTime.tryParse(json["created"] ?? '') ?? DateTime.now(),
      categoryName: json["category_name"]?.toString() ?? '',
      addressName: json["address_name"]?.toString() ?? '',
    );
  }

  String get createdString => DateFormat('yyyy-MM-dd').format(created);

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "phone": phone,
    "where": where,
    "nirden": nirden,
    "last_date": lastDate,
    "bring": isBring,
    "client": isClient,
    "price": price,
    "desc": desc,
    "img": img,
    "checked": checked,
    "category_name": categoryName,
    "address_name": addressName,
    "created": created.toIso8601String(),
  };
}

class LogistDetailModel {
  String id;
  String title;
  String author;
  String desc;
  String phone;
  String lastDate;
  String where;
  String nirden;
  bool isBring;
  bool isClient;
  String price;
  String url;
  DateTime created;
  List<ImageModel> images;
  String img;
  bool checked; // Пустой список
  double? latitude;
  double? longitude;
  String categoryName; // Пустой список
  String addressName;
  String category_id; // Пустой список
  String address_id;

  LogistDetailModel({
    required this.images,
    required this.id,
    required this.title,
    required this.author,
    required this.desc,
    required this.phone,
    required this.lastDate,
    required this.where,
    required this.nirden,
    required this.isBring,
    required this.isClient,
    required this.price,
    required this.url,
    required this.created,
    required this.img,
    required this.checked,
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    required this.addressName,
    required this. category_id, // Пустой список
    required this. address_id,
  });

  factory LogistDetailModel.fromJson(Map<String, dynamic> json) =>
      LogistDetailModel(
        id: json["pk"].toString(),
        title: json["name"] ?? '',
        author: json["author"]?.toString() ?? '',
        images:
            (json["images"] as List? ?? [])
                .map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
                .toList(),
        addressName: json["address_name"] ?? '',
        desc: json["text"] ?? '',
        phone: json["phone"]?.toString() ?? '',
        lastDate: json["last_date"] ?? '',
        where: json["where"] ?? '',
        nirden: json["nirden"] ?? '',
        isBring: json["bring"] ?? false,
        isClient: json["client"] ?? false,
        price: json["price"] ?? '',
        url: json["url"] ?? '',
        created: DateTime.tryParse(json["created"] ?? '') ?? DateTime.now(),
        img: json["img"] ?? '',
        checked: json["checked"] ?? false,
        categoryName: json["category_name"] ?? '',
        category_id: json["category_id"] ?? '',// Пустой список
        address_id: json["address_id"] ?? '',
        latitude:
            json["latitude"] != null
                ? double.tryParse(json["latitude"].toString())
                : null,
        longitude:
            json["longitude"] != null
                ? double.tryParse(json["longitude"].toString())
                : null,
      );

  Map<String, dynamic> toJson() => {
    "pk": id,
    "name": title,
    "author": author,
    "text": desc,
    "phone": phone,
    "last_date": lastDate,
    "where": where,
    "nirden": nirden,
    "bring": isBring,
    "client": isClient,
    "price": price,
    "url": url,
    "created": created.toIso8601String(),
    "img": img,
    "images": images.map((e) => e.toJson()).toList(),
    "checked": checked,
    "latitude": latitude,
    "longitude": longitude,
    "category_name": categoryName,
    "address_name": addressName,
  };
}

class LogistCarPageModel {
  String id;
  String title;
  String desc;
  String img;
  String categoryName;
  String phone;
  bool checked;
  String price;
  DateTime created;

  // Location
  double? latitude;
  double? longitude;

  LogistCarPageModel({
    required this.id,
    required this.title,
    required this.phone,
    required this.price,
    required this.desc,
    required this.img,
    required this.created,
    required this.categoryName,
    required this.checked,
    this.latitude,
    this.longitude,
  });

  factory LogistCarPageModel.fromJson(Map<String, dynamic> json) =>
      LogistCarPageModel(
        id: json["pk"].toString(),
        title: json["name"] ?? '',
        phone: json["phone"].toString(),
        price: json["price"]?.toString() ?? '',
        desc: json["text"] ?? '',
        img: json["img"] ?? '',
        checked: json["checked"] ?? false,
        created: DateTime.tryParse(json["created"] ?? '') ?? DateTime.now(),
        categoryName: json["category_name"] ?? '',
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
    "desc": desc,
    "img": img,
    "checked": checked,
    "category_name": categoryName,
    "created": created.toIso8601String(),
    "latitude": latitude,
    "longitude": longitude,
  };
}

class LogistCarDetailModel {
  String id;
  String title;
  String desc;
  String phone;
  String price;
  String img;
  DateTime created;
  String category;
  String address;
  String currentAddress;

  double? latitude;
  double? longitude;

  LogistCarDetailModel({
    required this.id,
    required this.title,
    required this.phone,
    required this.price,
    required this.desc,
    required this.img,
    required this.created,
    required this.category,
    required this.address,
    required this.currentAddress,
    this.latitude,
    this.longitude,
  });

  factory LogistCarDetailModel.fromJson(Map<String, dynamic> json) =>
      LogistCarDetailModel(
        id: json["pk"].toString(),
        title: json["name"] ?? '',
        phone: json["phone"]?.toString() ?? '',
        price: json["price"]?.toString() ?? '',
        desc: json["text"] ?? '',
        img: json["img"] ?? '',
        created: DateTime.tryParse(json["created"] ?? '') ?? DateTime.now(),
        category: json["category_name"] ?? '',
        address: json["address_name"] ?? '',
        currentAddress: json["current_address_name"] ?? '',
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
    "desc": desc,
    "img": img,
    "created": created.toIso8601String(),
    "category": category,
    "address": address,
    "current_address": currentAddress,
    "latitude": latitude,
    "longitude": longitude,
  };
}

class TopDetailModel {
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
  String thumbnail;

  TopDetailModel({
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
    required this.thumbnail,
  });

  factory TopDetailModel.fromJson(Map<String, dynamic> json) {
    return TopDetailModel(
      id: json["pk"].toString(),
      title: json["name"] ?? '',
      phone: json["phone"]?.toString() ?? '',
      price: json["price"]?.toString() ?? '',
      desc: removeHtmlTags(json["text"] ?? ''),
      img: json["img"] ?? '',
      images:
          (json["images"] as List?)?.map((e) => e["url"].toString()).toList() ??
          [],
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      address: json["address_name"] ?? '',
      category: json["category"] ?? '',
      thumbnail: json["thumbnail_url"] ?? '',
    );
  }

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
    "thumbnail": thumbnail,
    "created": created.toIso8601String(),
  };
}

//------------------------------------------------------------------------

class CarDetailModel {
  int pk; // JSON-da "pk": 1
  String name;
  int? year;
  String? color;
  String? engineVolume;
  int? mileage;
  String? gearbox;
  String? fuelType;
  String price;
  String? vinCode;
  String? description;
  String addressName;
  String categoryName;
  String address_id;
  String category_id;
  String phone;
  String img;
  List<ImageModel> images;
  // ... beýleki meýdançalar

  CarDetailModel({
    required this.pk,
    required this.name,
    this.year,
    this.color,
    this.engineVolume,
    this.mileage,
    this.gearbox,
    this.fuelType,
    required this.price,
    this.vinCode,
    this.description,
    required this.addressName,
    required this.categoryName,
    required this.address_id,
    required this.category_id,
    required this.phone,
    required this.img,
    required this.images,
  });

  factory CarDetailModel.fromJson(Map<String, dynamic> json) {
    return CarDetailModel(
      pk: json["pk"],
      name: json["name"] ?? '',
      year: json["year"],
      color: json["color"]?.toString(),
      engineVolume: json["engine_volume"]?.toString(),
      mileage: json["mileage"],
      gearbox: json["gearbox"]?.toString(),
      fuelType: json["fuel_type"]?.toString(),
      price: json["price"]?.toString() ?? '0',
      vinCode: json["vin_code"],
      description: json["description"],
      addressName: json["address_name"] ?? '',
      categoryName: json["category_name"] ?? '',
      address_id: json["address_id"] ?? '',
      category_id: json["category_id"] ?? '',
      phone: json["phone"] ?? '',
      img: json["img"] ?? '',
      images:
          (json["images"] as List? ?? [])
              .map((e) => ImageModel.fromJson(e))
              .toList(),
    );
  }
}

class SpareImageObject {
  final int id;
  final String url;

  SpareImageObject({required this.id, required this.url});

  factory SpareImageObject.fromJson(Map<String, dynamic> json) {
    return SpareImageObject(
      id: json['id'] ?? 0,
      url: json['url'] ?? json['image'] ?? '',
    );
  }
}

class SpareDetailModel {
  String id;
  String title;
  String desc;
  String img;
  List<ImageModel> images;
  String phone;
  String price;
  DateTime created;
  String address;
  String category;
  String address_id;
  String category_id;
  // Täze zapçast meýdanlary
  String? partNumber;
  int? year;
  String? condition;
  String? compatibility;
  final List<SpareImageObject>? imagesObjects;

  SpareDetailModel({
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
    required this.address_id,
    required this.category_id,
    this.partNumber,
    this.year,
    this.condition,
    this.compatibility,
    this.imagesObjects,
  });

  factory SpareDetailModel.fromJson(Map<String, dynamic> json) {
    // Suratlary işlemek: Django-dan "url" ýa-da "image" açary bilen gelip biler

    // Ýagdaýy (Condition) terjime etmek
    return SpareDetailModel(
      id: json["pk"].toString(),
      title: json["name"] ?? '',
      phone: json["phone"]?.toString() ?? '',
      price: json["price"]?.toString() ?? '',
      // Eger HTML tegleri bar bolsa öňki funksiýaňy ulanýarsyň
      desc: json["text"] != null ? removeHtmlTags(json["text"]) : '',
      img: json["img"] ?? '',
      images:
          (json["images"] as List? ?? [])
              .map((e) => ImageModel.fromJson(e))
              .toList(),
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      // Django-da 'address_name' we 'category_name' ulanýan bolsaň şony ýaz
      address: json["address_name"] ?? json["address"] ?? '',
      category: json["category_name"] ?? json["category"] ?? '',
      address_id: json["address_id"] ?? json["address"] ?? '',
      category_id: json["category_id"] ?? json["category"] ?? '',
      // Täze meýdanlar
      partNumber: json["part_number"]?.toString() ?? '-',
      compatibility: json["compatibility"]?.toString() ?? '',
      year:
          json["year"] is int
              ? json["year"]
              : int.tryParse(json["year"]?.toString() ?? ''),
      condition: json["condition"]?.toString() ?? 'used',
    );
  }

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
    "part_number": partNumber,
    "year": year,
    "condition": condition,
  };
}

class DetailModel {
  String id;
  String title;
  String desc;
  String img;
  List<ImageModel> images;
  String phone;
  String price;
  DateTime created;
  String address;
  String category;
  String address_id;
  String category_id;

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
    required this.address_id,
    required this.category_id,
  });

  factory DetailModel.fromJson(Map<String, dynamic> json) => DetailModel(
    id: json["pk"].toString(),
    title: json["name"] ?? '',
    phone: json["phone"].toString(),
    price: json["price"] ?? '',
    desc: removeHtmlTags(json["text"] ?? ''),
    img: json["img"] ?? '',
    images:
        (json["images"] as List? ?? [])
            .map((e) => ImageModel.fromJson(e))
            .toList(),
    created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
    address: json["address_name"] ?? '',
    category: json["category_name"] ?? '',
    address_id: json["address_id"] ?? '',
    category_id: json["category_id"] ?? '',
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
    "category_id": category_id,
    "address_id": address_id,
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

//---------------------------------------

class CategoryPage {
  String id;
  String title;
  final List<SubCategory> subcategories;

  CategoryPage({
    required this.id,
    required this.title,
    required this.subcategories,
  });

  factory CategoryPage.fromJson(Map<String, dynamic> json) => CategoryPage(
    id: json["pk"].toString(),
    title: json["name"],
    subcategories:
        (json['subcategories'] as List)
            .map((e) => SubCategory.fromJson(e))
            .toList(),
  );
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

class SubCategory {
  final int pk;
  final String name;

  SubCategory({required this.pk, required this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(pk: json['pk'], name: json['name']);
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
      CarouselPage(pk: json["pk"], name: json["name"], img: json["img_url"]);

  Map<String, dynamic> toJson() => {"pk": pk, "name": name, "img": img};
}
