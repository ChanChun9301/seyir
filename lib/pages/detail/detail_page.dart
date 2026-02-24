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

import '/utils/getData.dart';
import '/widgets/images.dart';
import '/widgets/text.dart';
import '/widgets/circulateContainer.dart';

class DetailPage extends StatefulWidget {
  final String id;
  final String title;
  final String query;

  const DetailPage({
    super.key,
    required this.query,
    required this.id,
    required this.title,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<DetailModel> futureData;
  List<String> images = [];
  bool _isImagesInitialized = false;

  @override
  void initState() {
    super.initState();
    futureData = getDetailDataApi(widget.query, widget.id);
  }

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
    return FutureBuilder<DetailModel>(
      future: futureData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularContainerMain();
        }

        final data = snapshot.data!;
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
              elevation: 6,
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
                /// IMAGES
                CarouselItemcard(
                  context: context,
                  child: CarouselSlider(
                    items:
                        images.map((img) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Images(
                              images: images,
                              id: images.indexOf(img),
                            ),
                          );
                        }).toList(),
                    options: CarouselOptions(
                      autoPlay: true,
                      viewportFraction: 1,
                      aspectRatio: 2,
                    ),
                  ),
                ),

                /// TITLE + CATEGORY
                Itemcard(
                  context: context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BigText(text: data.title),
                      const SizedBox(height: 6),
                      SmallText(text: 'Kategoriýasy: ${data.category}'),
                    ],
                  ),
                ),

                /// INFO
                Itemcard(
                  context: context,
                  child: Column(
                    children: [
                      InfoRow(
                        context: context,
                        icon: Icons.home_work_outlined,
                        text: data.address,
                      ),
                      InfoRow(
                        context: context,
                        icon: Icons.call,
                        text: data.phone,
                      ),
                      InfoRow(
                        context: context,
                        icon: Icons.price_check_rounded,
                        text: '${data.price} TMT',
                      ),
                    ],
                  ),
                ),

                /// DESCRIPTION
                Itemcard(
                  context: context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Beýan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Bricolage',
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.desc,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Bricolage',
                          color: Theme.of(context).colorScheme.onSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          /// CALL BUTTON
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _makeCall(data.phone),
                icon: const Icon(
                  CupertinoIcons.phone,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Habarlaşmak',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 1,
                    fontFamily: "Bricolage",
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// helpers
  bool snapshotHasPhone(BuildContext context) => true;

  String snapshotPhone(BuildContext context) {
    // тут телефон уже есть в data, логика оставлена простой
    return '';
  }
}
