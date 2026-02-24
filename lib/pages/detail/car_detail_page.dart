// ignore_for_file: file_names

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/navbar.dart';
import '/utils/models.dart';
import '_card.dart';
import '_card_carousel.dart';
import '_infoRow.dart';
import 'package:seyir/api/fetch_car.dart';
import '/widgets/images.dart';
import '/widgets/text.dart';
import '/widgets/circulateContainer.dart';

class CarDetailPage extends StatefulWidget {
  final String id;
  final String title;

  const CarDetailPage({super.key, required this.id, required this.title});

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  late Future<CarDetailModel> futureData;
  List<String> images = [];
  bool _isImagesInitialized = false;

  @override
  void initState() {
    super.initState();
    futureData = getCarDetailApi(int.parse(widget.id));
  }

  // Jaň etmek funksiýasy
  Future<void> _makeCall(String phoneNumber) async {
    // 1. Nomeri arassalamak (boşluklary we gereksiz simwollary aýyrmak)
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');

    // 2. Formatirlemek logikasy
    if (!cleanNumber.startsWith('+')) {
      if (cleanNumber.startsWith('993')) {
        // Eger 993 bilen başlaýan bolsa, diňe + goşmaly
        cleanNumber = '+$cleanNumber';
      } else {
        // Galan ýagdaýlarda (meselem 65...) öňüne +993 goşmaly
        cleanNumber = '+993$cleanNumber';
      }
    }

    final Uri uri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        log("Jaň edip bolmady: $cleanNumber");
      }
    } catch (e) {
      log("Ýalňyşlyk: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CarDetailModel>(
      future: futureData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: CircularContainerMain());
        }

        final data = snapshot.data!;

        // Suratlar sanawyny düzmek
        if (!_isImagesInitialized) {
          images.clear();
          // Esasy suraty goşýarys
          if (data.img.isNotEmpty) images.add(data.img);

          // Goşmaça suratlaryň URL-lerini ImageModel-den alýarys
          // Üns beriň: v['url'] däl-de, v.url bolmaly!
          images.addAll(data.images.map((v) => v.url).toList());

          _isImagesInitialized = true;
        }

        return Scaffold(
          drawer: const NavBar(),
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: AppBar(
              centerTitle: true,
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Bricolage",
                  color: Colors.white,
                ),
              ),
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.sort_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                /// 1. SURATLAR (Carousel)
                CarouselItemcard(
                  context: context,
                  child: CarouselSlider(
                    items:
                        images.isNotEmpty
                            ? images.map((img) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Images(
                                  images: images,
                                  id: images.indexOf(img),
                                ),
                              );
                            }).toList()
                            : [
                              // Eger suratlar sanawy boş bolsa, asset-den suraty görkezýäris
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/no-image.jpg',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ],
                    options: CarouselOptions(
                      autoPlay:
                          images.length >
                          1, // Diňe 1-den köp surat bolsa auto-play işlesin
                      viewportFraction: 1,
                      aspectRatio: 2,
                    ),
                  ),
                ),

                /// 2. ADY WE BAHASY
                Itemcard(
                  context: context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BigText(text: data.name),
                      const SizedBox(height: 6),
                      InfoRow(
                        context: context,
                        icon: Icons.money,
                        text: 'Bahasy: ${data.price} TMT',
                      ),
                    ],
                  ),
                ),

                /// 3. ULAG MAGLUMATLARY (JSON-dan gelýän)
                Itemcard(
                  context: context,
                  child: Column(
                    children: [
                      InfoRow(
                        context: context,
                        icon: Icons.calendar_today,
                        text: "Ýyly: ${data.year}",
                      ),
                      InfoRow(
                        context: context,
                        icon: Icons.speed,
                        text: "Ýörişi: ${data.mileage} km",
                      ),
                      InfoRow(
                        context: context,
                        icon: Icons.local_gas_station,
                        text: "Ýangyç: ${data.fuelType}",
                      ),
                      InfoRow(
                        context: context,
                        icon: Icons.settings_suggest,
                        text: "Korobka: ${data.gearbox}",
                      ),
                      InfoRow(
                        context: context,
                        icon: Icons.settings_suggest,
                        text: "Motory: ${data.engineVolume}",
                      ),
                      InfoRow(
                        context: context,
                        icon: Icons.color_lens_outlined,
                        text: "Renki: ${data.color}",
                      ),
                    ],
                  ),
                ),

                Itemcard(
                  context: context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow(
                        context: context,
                        icon: Icons.location_on_outlined,
                        text: data.addressName,
                      ),
                      const Divider(),
                      InfoRow(
                        context: context,
                        icon: Icons.category_outlined,
                        text: data.categoryName,
                      ),
                    ],
                  ),
                ),

                /// 4. ÝERLEŞÝÄN ÝERI WE BEÝAN
                Itemcard(
                  context: context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Beýan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Bricolage',
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.description ?? "Beýan ýok",
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          fontFamily: 'Bricolage',
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          /// 5. JAŇ ETMEK DÜWMESI (Bottom Navigation)
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _makeCall(data.phone),
              icon: const Icon(CupertinoIcons.phone, color: Colors.white),
              label: const Text(
                'Habarlaşmak',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
