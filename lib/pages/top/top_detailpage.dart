// ignore_for_file: file_names

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/navbar.dart';
import '../detail/_card_carousel.dart';
import '/utils/constants.dart';
import '/utils/getData.dart';
import '/utils/models.dart';
import '/widgets/images.dart';
import '/widgets/text.dart';
import '/widgets/circulateContainer.dart';

class TopDetailPage extends StatefulWidget {
  final String id;
  final String title;

  const TopDetailPage({super.key, required this.id, required this.title});

  @override
  State<TopDetailPage> createState() => _TopDetailPageState();
}

class _TopDetailPageState extends State<TopDetailPage> {
  late Future<DetailModel> futureCar;
  final CarouselSliderController csc = CarouselSliderController();
  List<String> images = [];
  bool _isImagesInitialized = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    futureCar = getTopDetailDataApi(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: Theme.of(context).colorScheme.background,

      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: "Bricolage",
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),

      body: FutureBuilder<DetailModel>(
        future: futureCar,
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

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  /// ================= IMAGES =================
                  Column(
                    children: [
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
                      const SizedBox(height: 6),

                      /// INDICATORS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            images.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () => csc.animateToPage(entry.key),
                                child: Container(
                                  width: _currentIndex == entry.key ? 16 : 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        _currentIndex == entry.key
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Colors.grey.shade400,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  /// ================= TITLE =================
                  _card(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BigText(text: data.title),
                        const SizedBox(height: 6),
                        SmallText(text: 'Kategoriýasy: ${data.category}'),
                      ],
                    ),
                  ),

                  /// ================= INFO =================
                  _card(
                    context,
                    Column(
                      children: [
                        _infoRow(context, Icons.location_on, data.address),
                        _infoRow(context, Icons.call, data.phone),
                        _infoRow(
                          context,
                          Icons.price_check,
                          '${data.price} TMT',
                        ),
                      ],
                    ),
                  ),

                  /// ================= DESCRIPTION =================
                  _card(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Beýan',
                          style: TextStyle(
                            fontFamily: 'Bricolage',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.desc,
                          style: TextStyle(
                            fontFamily: "Bricolage",
                            fontSize: 12,
                            height: 1.4,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ================= CALL BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final call = Uri(
                          scheme: 'tel',
                          path: '+993${data.phone}',
                        );
                        launchUrl(call);
                      },
                      icon: const Icon(
                        CupertinoIcons.phone,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Habarlaşmak',
                        style: TextStyle(
                          fontFamily: "Bricolage",
                          color: Colors.white,
                          letterSpacing: 1,
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ================= CARD =================
  Widget _card(BuildContext context, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      width: width(context),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  /// ================= INFO ROW =================
  Widget _infoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: "Bricolage",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
