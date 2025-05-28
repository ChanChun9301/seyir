import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../widgets/html_widget.dart';
import '/utils/constants.dart';
import '/widgets/circulateContainer.dart';
import '/widgets/text.dart';
import '../../component/navbar.dart';
import 'news_imagefull.dart';
import '/utils/models.dart';
import 'package:http/http.dart' as http;

class NewsDetailPage extends StatefulWidget {
  final String id;
  final String title;
  const NewsDetailPage({Key? key, required this.id, required this.title})
      : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late Future<NewsPage> futureCar;
  final CarouselSliderController csc = CarouselSliderController();
  // late WebViewController _controller;
  // int _currentIndex = 0;

  Future<NewsPage> getDataApi() async {
    final response =
        await http.get(Uri.parse('$baseUrl/news-list/${widget.id}'));
    if (response.statusCode == 200) {
      return NewsPage.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
    } else {
      throw Exception('Maglumat yok');
    }
  }

  @override
  void initState() {
    super.initState();
    futureCar = getDataApi();
  }

  PageController cs = PageController();
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              centerTitle: true,
              title: Text(
                widget.title,
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2,
                    fontFamily: "Bricolage",
                    fontSize: 20,
                    color: Colors.white),
              ),
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.arrow_back_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/news');
                    },
                  );
                },
              ),
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30))),
            )),
        backgroundColor: Theme.of(context).colorScheme.background,
        drawer: const NavBar(),
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: FutureBuilder(
              future: futureCar,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SafeArea(
                    child: Column(children: [
                      Padding(
                        padding: EdgeInsets.all(height(context) / 84.4),
                        child: Column(
                          children: [
                            snapshot.data!.img.isNotEmpty
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewsImageFullScreen(
                                                    img: snapshot.data!.img,
                                                  )));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  height(context) / 84.4)),
                                          child: Image.network(
                                            snapshot.data!.img,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          )),
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
                          ],
                        ),
                      ),
                      Container(
                        width: w,
                        margin: EdgeInsets.only(
                            top: 10,
                            left: height(context) / 84.4,
                            right: height(context) / 84.4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius:
                              BorderRadius.all(Radius.circular(h / 84.4)),
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
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: BigText(
                                text: snapshot.data!.title,
                              ),
                            ),
                            const Divider(
                              color: Colors.grey,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SmallText(
                                    text: snapshot.data!.category,
                                  ),
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text('Çeşme:\t${snapshot.data!.author}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Bricolage',
                                    fontSize: 12,
                                  )),
                            ),
                            HtmlWidget(text: snapshot.data!.desc)
                          ],
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
