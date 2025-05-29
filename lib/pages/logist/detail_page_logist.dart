// ignore_for_file: file_names

import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:seyir/main.dart';
import '/utils/constants.dart';
import '/utils/getData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/widgets/images.dart';
import '/widgets/text.dart';
import '/widgets/circulateContainer.dart';
import '../../component/navbar.dart';
import '/utils/models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Changed from Maps_flutter

class LogistDetailPage extends StatefulWidget {
  final String id;
  final String title;
  
  const LogistDetailPage({Key? key, required this.id,required this.title})
    : super(key: key);

  @override
  State<LogistDetailPage> createState() => _CarLogistDetailPageState();
}

class _CarLogistDetailPageState extends State<LogistDetailPage> {
  late Future<LogistDetailModel> futureCar;
  int _currentIndex = 0;
  List<String> images = [];
  var now = DateTime.now();
  int day = DateTime.now().day;
  int month = DateTime.now().month;
  int year = DateTime.now().year;

  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  LatLng? _center; // To store the location from API
  final CarouselSliderController csc = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    futureCar = getLogistDetailDataApi(widget.id);
    // After fetching data, update _center and add marker
    futureCar.then((data) {
      if (data.latitude != null && data.longitude != null) {
        setState(() {
          _center = LatLng(data.latitude!, data.longitude!);
          _markers.add(
            Marker(
              markerId: MarkerId(widget.id),
              position: _center!,
              infoWindow: InfoWindow(title: widget.title),
            ),
          );
        });
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
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
              color: Colors.white,
            ),
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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: const NavBar(),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: futureCar,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int lastday = int.parse(snapshot.data!.lastDate.substring(8, 10));
              int lastmonth = int.parse(
                snapshot.data!.lastDate.substring(5, 7),
              );
              int lastyear = int.parse(snapshot.data!.lastDate.substring(0, 4));
              images.clear();
              images.addAll(snapshot.data!.images);

              // Update _center and _markers once data is available
              if (_center == null &&
                  snapshot.data!.latitude != null &&
                  snapshot.data!.longitude != null) {
                _center = LatLng(
                  snapshot.data!.latitude!,
                  snapshot.data!.longitude!,
                );
                _markers.add(
                  Marker(
                    markerId: MarkerId(widget.id),
                    position: _center!,
                    infoWindow: InfoWindow(title: widget.title),
                  ),
                );
              }

              return SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(height(context) / 84.4),
                      child: Column(
                        children: [
                          images.isNotEmpty
                              ? CarouselSlider(
                                items:
                                    images
                                        .asMap()
                                        .entries
                                        .map(
                                          (e) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 0,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                  height(context) / 84.4,
                                                ),
                                              ),
                                              child: Images(
                                                images: images,
                                                id: e.key,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                carouselController: csc,
                                options: CarouselOptions(
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  autoPlay: true,
                                  aspectRatio: 2,
                                  viewportFraction: 1,
                                  onPageChanged:
                                      (index, reason) => {
                                        setState(() {
                                          _currentIndex = index;
                                        }),
                                      },
                                ),
                              )
                              : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(height(context) / 84.4),
                                  ),
                                  child: Image.asset(
                                    'assets/no-image.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                images.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  return GestureDetector(
                                    onTap: () => csc.animateToPage(index),
                                    child: Container(
                                      width: _currentIndex == index ? 17 : 7,
                                      height: 7.0,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3.0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          height(context) / 84.4,
                                        ),
                                        color:
                                            _currentIndex == index
                                                ? const Color.fromARGB(
                                                  255,
                                                  161,
                                                  93,
                                                  83,
                                                )
                                                : Colors.teal,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                    BigText(text: snapshot.data!.title),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Ahyrky sene:\t',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Bricolage',
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          (snapshot.data!.created.toString() !=
                                                  formattedDate)
                                              ? snapshot.data!.lastDate
                                                  .toString()
                                              : snapshot.data!.lastDate
                                                  .toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color:
                                                (lastmonth >= month &&
                                                        lastday >= day &&
                                                        lastyear >= year)
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.secondary
                                                    : Colors.red,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Bricolage',
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          (snapshot.data!.isBring == true)
                                              ? 'Getirmeli'
                                              : 'Alyp gitmeli',
                                          style: TextStyle(
                                            color:
                                                (snapshot.data!.isBring == true)
                                                    ? (SeyirApp
                                                                .themeNotifier
                                                                .value ==
                                                            ThemeMode.light
                                                        ? Colors.green.shade500
                                                        : Colors.grey.shade200)
                                                    : Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Bricolage',
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(
                                          (snapshot.data!.isBring == true)
                                              ? CupertinoIcons
                                                  .arrow_down_square_fill
                                              : CupertinoIcons
                                                  .arrow_up_square_fill,
                                          size: 20,
                                          color:
                                              (snapshot.data!.isBring == true)
                                                  ? Colors.green
                                                  : Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.grey),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SmallText(
                                text:
                                    'Kategoriýasy: ${snapshot.data!.category.toString()}',
                              ),
                              SmallText(
                                text:
                                    (snapshot.data!.created
                                                .toString()
                                                .substring(0, 10) ==
                                            formattedDate)
                                        ? 'Şu gün'
                                        : snapshot.data!.created
                                            .toString()
                                            .substring(0, 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: width(context),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Ýeri:',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 12,
                                        fontFamily: "Bricolage",
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                      ),
                                    ),
                                    Text(
                                      'Telefon belgi:',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontFamily: "Bricolage",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                      ),
                                    ),
                                    Text(
                                      'Bahasy:',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 12,
                                        fontFamily: "Bricolage",
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      snapshot.data!.address.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "Bricolage",
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data!.phone,
                                      style: TextStyle(
                                        fontFamily: "Bricolage",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                      ),
                                    ),
                                    Text(
                                      '${snapshot.data!.price} TMT',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "Bricolage",
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.grey),
                                SizedBox(
                                  child: Text(
                                    removeHtmlTags(snapshot.data!.desc),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    // Map Integration
                    if (_center !=
                        null) // Only show map if location data is available
                      Container(
                        height: 200, // Adjust height as needed
                        margin: EdgeInsets.symmetric(
                          horizontal: height(context) / 84.4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(height(context) / 84.4),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(99, 99, 99, 0.2),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(height(context) / 84.4),
                          ),
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: _center!,
                              zoom: 15.0, // Adjust zoom level as needed
                            ),
                            markers: _markers,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: height(context) / 84.4,
                      ),
                      width: width(context),
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final call = Uri(
                            scheme: 'tel',
                            path: '+993${snapshot.data!.phone}',
                          );
                          if (await canLaunchUrl(call)) {
                            launchUrl(call);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(height(context) / 84.4),
                            ),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.phone,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
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
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return const CircularContainerMain();
            }
          },
        ),
      ),
    );
  }
}
