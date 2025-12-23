import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import './constants.dart';

class ImageModel {
  final int pk;
  final String url;

  ImageModel({required this.pk, required this.url});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      pk:
          (json['pk'] is int)
              ? json['pk']
              : (int.tryParse(json['pk']?.toString() ?? '') ??
                  0), // Handle int/String for pk
      url: json['url']?.toString() ?? '', // Ensure url is always a String
    );
  }

  Map<String, dynamic> toJson() {
    return {'pk': pk, 'url': url};
  }
}

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
  String categoryName; // теперь список строк
  String addressName; // список строк
  String phone;
  String where;
  String nirden;
  bool checked;
  String lastDate;
  bool isBring;
  bool isClient;
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

  factory LogistPageModel.fromJson(Map<String, dynamic> json) =>
      LogistPageModel(
        id: json["pk"].toString(),
        title: json["name"] ?? '',
        phone: json["phone"].toString(),
        price: json["price"]?.toString() ?? '',
        where: json["where"] ?? '',
        nirden: json["nirden"] ?? '',
        lastDate: json["last_date"] ?? '',
        isBring: json["bring"] ?? false,
        isClient: json["client"] ?? false,
        desc: json["text"] ?? '',
        img: json["img"] ?? '',
        checked: json["checked"] ?? false,
        created: DateTime.tryParse(json["created"] ?? '') ?? DateTime.now(),
        categoryName: json["category_name"] ?? '',
        addressName: json["address_name"] ?? '',
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
        addressName: json["address"] ?? '',
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
        categoryName: json["category"] ?? '',
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
      images: (json["images"] as List?)
              ?.map((e) => e["url"].toString())
              .toList() 
          ?? [],
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

class CarDetailModel {
  String id;
  String title;
  String desc;
  String img;
  List<String> images;
  String phone;
  String price;
  DateTime created;
  String address;
  String currentAddress;
  String category;
  double? latitude;
  double? longitude;
  String thumbnail;
  bool checked;

  CarDetailModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.img,
    required this.images,
    required this.phone,
    required this.price,
    required this.created,
    required this.address,
    required this.currentAddress,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.thumbnail,
    required this.checked,
  });

  factory CarDetailModel.fromJson(Map<String, dynamic> json) {
    return CarDetailModel(
      id: json["pk"].toString(),
      title: json["name"] ?? '',
      desc: removeHtmlTags(json["text"] ?? ''),
      img: json["img"] ?? '',
      images: (json["images"] as List?)
              ?.map((e) => e["url"].toString())
              .toList() 
          ?? [],
      phone: json["phone"]?.toString() ?? '',
      price: json["price"]?.toString() ?? '',
      created: DateTime.tryParse(json["created"] ?? '') ?? DateTime.now(),
      address: json["address_name"] ?? '',
      currentAddress: json["current_address_name"] ?? '',
      category: json["category_name"] ?? '',
      latitude: json["latitude"] != null ? double.tryParse(json["latitude"].toString()) : null,
      longitude: json["longitude"] != null ? double.tryParse(json["longitude"].toString()) : null,
      thumbnail: json["thumbnail_url"] ?? '',
      checked: json["checked"] ?? false,
    );
  }

  String get createdString => DateFormat('yyyy-MM-dd').format(created);

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "desc": desc,
        "img": img,
        "images": images,
        "phone": phone,
        "price": price,
        "created": created.toIso8601String(),
        "address": address,
        "currentAddress": currentAddress,
        "category": category,
        "latitude": latitude,
        "longitude": longitude,
        "thumbnail": thumbnail,
        "checked": checked,
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
      CarouselPage(pk: json["pk"], name: json["name"], img: json["img_url"]);

  Map<String, dynamic> toJson() => {"pk": pk, "name": name, "img": img};
}
