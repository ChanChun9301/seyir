// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../component/navbar.dart';
import '/utils/models.dart';
import '../detail/_card.dart';
import '../detail/_infoRow.dart';
import '../detail/_card_carousel.dart';
import '/api/fetch_spare.dart';
import '/widgets/images.dart';
import '/widgets/text.dart';
import '/widgets/circulateContainer.dart';

class SpareDetailPage extends StatefulWidget {
  final String id;
  final String title;

  const SpareDetailPage({super.key, required this.id, required this.title});

  @override
  State<SpareDetailPage> createState() => _SpareDetailPageState();
}

// ... (imports)

class _SpareDetailPageState extends State<SpareDetailPage> {
  late Future<SpareDetailModel> futureData;
  SpareDetailModel? loadedData;
  bool _isImagesInitialized = false;
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    futureData = getSpareDetailApi(int.parse(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0, // Has dury dizaýn üçin
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "Bricolage",
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: FutureBuilder<SpareDetailModel>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularContainerMain();
          } else if (snapshot.hasError) {
            return const Center(child: Text("Maglumat tapylmady"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Maglumat ýok"));
          }

          final data = snapshot.data!;
          loadedData = data;

          if (!_isImagesInitialized) {
            images.clear();
            // Esasy suraty goşýarys
            if (data.img.isNotEmpty) images.add(data.img);

            // Goşmaça suratlaryň URL-lerini ImageModel-den alýarys
            // Üns beriň: v['url'] däl-de, v.url bolmaly!
            images.addAll(data.images.map((v) => v.url).toList());

            _isImagesInitialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                /// 1. IMAGES CAROUSEL
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
                      autoPlay: images.length > 1,
                      viewportFraction: 1,
                      aspectRatio: 2,
                    ),
                  ),
                ),

                /// 2. MAIN TITLE & PRICE & DATE
                Itemcard(
                  context: context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BigText(text: data.title),

                      // Modeldäki senäni görkezýär
                      SmallText(
                        text: DateFormat(
                          'dd.MM.yyyy HH:mm',
                        ).format(data.created), // 18.11.2025 19:38
                      ),
                    ],
                  ),
                ),
                Itemcard(
                  context: context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        Icons.category_outlined,
                        'Kategoriýa',
                        data.category,
                      ),

                      if (data.year != null && data.year != 0)
                        _buildDetailRow(
                          Icons.calendar_month_outlined,
                          'Ýyly',
                          data.year.toString(),
                        ),

                      if (data.condition != null && data.condition!.isNotEmpty)
                        _buildDetailRow(
                          Icons.build_circle_outlined,
                          'Ýagdaýy',
                          data.condition!,
                        ),

                      if (data.partNumber != null &&
                          data.partNumber!.isNotEmpty)
                        _buildDetailRow(
                          Icons.fingerprint,
                          'Zapçast №',
                          data.partNumber!,
                        ),

                      _buildDetailRow(
                        Icons.location_on_outlined,
                        'Salgy',
                        data.address,
                      ),

                      _buildDetailRow(
                        Icons.price_change,
                        'Bahasy',
                        '${data.price} TMT',
                      ),
                    ],
                  ),
                ),

                /// 4. COMPATIBILITY (Uýgunlaşygy) - Eger bar bolsa
                if (data.compatibility != null &&
                    data.compatibility!.isNotEmpty)
                  Itemcard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Uýgunlaşygy (Compatibility)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Bricolage',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.compatibility!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                /// 5. DESCRIPTION
                Itemcard(
                  context: context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Beýan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Bricolage',
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.desc,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
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
          );
        },
      ),
      bottomNavigationBar:
          loadedData == null ? const SizedBox() : _buildCallButton(),
    );
  }

  // InfoRow-y has tertipli görkezmek üçin kömekçi widget
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InfoRow(context: context, icon: icon, text: "$label: $value"),
    );
  }

  Widget _buildCallButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          if (loadedData!.phone.isNotEmpty) {
            final uri = Uri.parse('tel:+993${loadedData!.phone}');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          }
        },
        icon: const Icon(
          CupertinoIcons.phone_fill,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          'JAŇ ETMEK',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
