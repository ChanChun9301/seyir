// ignore_for_file: file_names

// import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:seyir/widgets/images.dart';
import '/utils/constants.dart';
import '/utils/getData.dart';
import 'package:flutter/material.dart';
import '/widgets/text.dart';
import '/widgets/circulateContainer.dart';
import '../component/navbar.dart';
import '/utils/models.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final String id;
  final String title;
  final String query;
  const DetailPage(
      {Key? key, required this.query, required this.id, required this.title})
      : super(key: key);

  @override
  State<DetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<DetailPage> {
  late Future<DetailModel> futureData;
  List<String> images = [];
  final CarouselSliderController csc = CarouselSliderController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    futureData = getDetailDataApi(widget.query, widget.id);
    debugPrint(getDetailDataApi(widget.query, widget.id).toString());
  }

  PageController cs = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              centerTitle: true,
              title: Text(
                widget.title,
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2,
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
              future: futureData,
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
                      Container(
                        margin: EdgeInsets.only(
                            top: 10,
                            left: height(context) / 84.4,
                            right: height(context) / 84.4),
                        padding: const EdgeInsets.all(10),
                        width: width(context),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.all(
                              Radius.circular(height(context) / 84.4)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(99, 99, 99, 0.2),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: Offset(
                                0,
                                2,
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              child: Text(
                                snapshot.data!.title,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 12,
                                  fontFamily: "Bricolage",
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ýeri:',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 10,
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
                                    fontSize: 10,
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
                                    fontSize: 10,
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
                                    fontSize: 10,
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
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                                Text(
                                  '${snapshot.data!.price} TMT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: "Bricolage",
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: Colors.grey,
                            ),
                            SizedBox(
                              child: Text(
                                snapshot.data!.desc,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: height(context) / 84.4),
                        width: width(context),
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final call = Uri(
                                scheme: 'tel',
                                path: '+993${snapshot.data!.phone}');
                            if (await canLaunchUrl(call)) {
                              launchUrl(call);
                            }
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
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Habarlaşmak',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
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
