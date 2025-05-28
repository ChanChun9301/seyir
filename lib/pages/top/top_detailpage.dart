// ignore_for_file: file_names
// import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:seyir/widgets/html_widget.dart';
import 'package:seyir/widgets/images.dart';

import '/utils/constants.dart';
import '/utils/getData.dart';
import 'package:flutter/material.dart';
import '/widgets/text.dart';
import '/widgets/circulateContainer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../component/navbar.dart';
import '/utils/models.dart';

class TopDetailPage extends StatefulWidget {
  final String id;
  final String title;
  const TopDetailPage({Key? key, required this.id, required this.title})
      : super(key: key);

  @override
  State<TopDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<TopDetailPage> {
  late Future<DetailModel> futureCar;
  final CarouselSliderController csc = CarouselSliderController();
  List<String> images = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    futureCar = getTopDetailDataApi(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 10,
              centerTitle: true,
              title: Text(
                widget.title,
                style: const TextStyle(
                    letterSpacing: 0,
                    fontFamily: "Bricolage",
                    fontSize: 16,
                    color: Colors.white),
              ),
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.arrow_back_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30))),
            )),
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        drawer: const NavBar(),
        body: SingleChildScrollView(
          child: FutureBuilder(
              future: futureCar,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  images.clear();
                  images.addAll(snapshot.data!.images);

                  return SafeArea(
                    child: Column(children: [
                      Padding(
                        padding: EdgeInsets.all(height(context) / 84.4),
                        child: Column(
                          children: [
                            images.isNotEmpty
                                ? CarouselSlider(
                                    items: images
                                        .asMap()
                                        .entries
                                        .map((e) => Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 0),
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              height(context) /
                                                                  84.4)),
                                                  child: Images(
                                                    images: images,
                                                    id: e.key,
                                                  )),
                                            ))
                                        .toList(),
                                    carouselController: csc,
                                    options: CarouselOptions(
                                      scrollPhysics:
                                          const BouncingScrollPhysics(),
                                      autoPlay: true,
                                      aspectRatio: 2,
                                      viewportFraction: 1,
                                      onPageChanged: (index, reason) => {
                                        setState(() {
                                          _currentIndex = index;
                                        })
                                      },
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                height(context) / 84.4)),
                                        child: Image.asset(
                                          'assets/no-image.jpg',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )),
                                  ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: images.asMap().entries.map((entry) {
                                int index = entry.key;
                                return GestureDetector(
                                  onTap: () => csc.animateToPage(index),
                                  child: Container(
                                    width: _currentIndex == index ? 17 : 7,
                                    height: 7.0,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            height(context) / 84.4),
                                        color: _currentIndex == index
                                            ? const Color.fromARGB(
                                                255, 161, 93, 83)
                                            : Colors.teal),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      BigText(
                        text: snapshot.data!.title,
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SmallText(
                              text:
                                  'Kategoriýasy: ${snapshot.data!.category.toString()}'),
                          SmallText(
                              text: (snapshot.data!.created
                                          .toString()
                                          .substring(0, 10) ==
                                      formattedDate)
                                  ? 'Şu gün'
                                  : snapshot.data!.created
                                      .toString()
                                      .substring(0, 10))
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: width(context),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ýeri:',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 12,
                                    fontFamily: "Bricolage",
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                                Text(
                                  'Telefon belgi:',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontFamily: "Bricolage",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                                Text(
                                  'Bahasy:',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 12,
                                    fontFamily: "Bricolage",
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  snapshot.data!.address.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Bricolage",
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                                Text(
                                  snapshot.data!.phone,
                                  style: TextStyle(
                                    fontFamily: "Bricolage",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                                Text(
                                  '${snapshot.data!.price} TMT',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Bricolage",
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      SizedBox(
                          child: HtmlWidget(
                        text: snapshot.data!.desc,
                      )),
                      const SizedBox(height: 10),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: height(context) / 84.4),
                        width: width(context),
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            final call = Uri(
                                scheme: 'tel',
                                path: '+993${snapshot.data!.phone}');
                            launchUrl(call);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(height(context) / 84.4))),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.phone,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Habarlaşmak',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: "Bricolage",
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  );
                } else {
                  return const CircularContainerMain();
                }
              }),
        ));
  }
}
