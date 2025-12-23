// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../component/navbar.dart';
import '/utils/models.dart';
import '/utils/constants.dart';
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

  @override
  void initState() {
    super.initState();
    futureData = getDetailDataApi(widget.query, widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: Theme.of(context).colorScheme.background,

      appBar: AppBar(
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),

      body: FutureBuilder<DetailModel>(
        future: futureData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularContainerMain();
          }

          final data = snapshot.data!;
          images.clear();
          images.add(data.img);
          images.addAll(data.images);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                /// IMAGES
                _card(
                  context,
                  CarouselSlider(
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

                /// INFO
                _card(
                  context,
                  Column(
                    children: [
                      _infoRow(Icons.home_work_outlined, data.address),
                      _infoRow(Icons.call, data.phone),
                      _infoRow(Icons.price_check_rounded, '${data.price} TMT'),
                    ],
                  ),
                ),

                /// DESCRIPTION
                _card(
                  context,
                  Column(
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
                          height: 1.4,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),

      /// CALL BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (snapshotHasPhone(context)) {
                final uri = Uri(
                  scheme: 'tel',
                  path: '+993${snapshotPhone(context)}',
                );
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri);
                }
              }
            },
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
  }

  /// CARD
  Widget _card(BuildContext context, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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

  /// INFO ROW
  Widget _infoRow(IconData icon, String text) {
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
                fontSize: 12,
                fontFamily: "Bricolage",
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// helpers
  bool snapshotHasPhone(BuildContext context) => true;

  String snapshotPhone(BuildContext context) {
    // тут телефон уже есть в data, логика оставлена простой
    return '';
  }
}
