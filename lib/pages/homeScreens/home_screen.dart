import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../widgets/circulateContainer.dart';
import '../../component/navbar.dart';
import '../../utils/constants.dart';
import '../../utils/models.dart';
import '../../widgets/text.dart';

import '../controls/carousel_control.dart';
import '../lists/main_list.dart';
import '../logist/logistmain_list.dart';
import '../news/news_mainlist.dart';
import '../top/top_detailpage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController(
    viewportFraction: 1 / 3.5,
  );
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final CarouselControl _carouselControl = Get.put(CarouselControl());

  List<PageModel> _items = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isRefreshing = false;

  int _currentCarouselIndex = 0;

  Timer? _backButtonTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
    _carouselControl.fetchCarouselItems();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    _backButtonTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final newItems = await _fetchPageData();

    setState(() {
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(newItems);
        _currentPage++;
      }
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _currentPage = 1;
      _items.clear();
      _hasMore = true;
    });

    await _loadData();

    setState(() => _isRefreshing = false);
  }

  Future<List<PageModel>> _fetchPageData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/topmain-list/?checked=True&page=$_currentPage'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        final List results = data['results'] ?? [];
        return results.map((e) => PageModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load data: $e');
    }
    return [];
  }

  Future<bool> _onWillPop() async {
    if (_backButtonTimer != null && _backButtonTimer!.isActive) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yza çykmak üçin ýene bir gezek basyň!')),
      );
      _backButtonTimer = Timer(const Duration(seconds: 2), () {
        _backButtonTimer = null;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            backgroundColor: theme.colorScheme.primary,
            elevation: 10,
            centerTitle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            leading: Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(
                      Icons.sort_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
            ),
            title: const Text(
              'Seýir',
              style: TextStyle(
                letterSpacing: 2,
                fontFamily: 'Bricolage',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ),
        ),

        extendBodyBehindAppBar: true,
        drawer: const NavBar(),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            controller: _scrollController,
            children: [
              Obx(() {
                final carouselItems = _carouselControl.carouselItems;
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(
                    height / 84.4,
                    10,
                    height / 84.4,
                    0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child:
                      carouselItems.isNotEmpty
                          ? CarouselSlider(
                            items:
                                carouselItems
                                    .map(
                                      (e) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            height / 42.2,
                                          ),
                                          child: Image.network(
                                            e.img,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            carouselController: _carouselController,
                            options: CarouselOptions(
                              scrollPhysics: const BouncingScrollPhysics(),
                              autoPlay: true,
                              aspectRatio: 2,
                              viewportFraction: 1,
                              onPageChanged: (index, _) {
                                setState(() => _currentCarouselIndex = index);
                              },
                            ),
                          )
                          : Image.asset(
                            'assets/no-image.jpg',
                            fit: BoxFit.fill,
                          ),
                );
              }),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    _carouselControl.carouselItems.asMap().entries.map((entry) {
                      final idx = entry.key;
                      return GestureDetector(
                        onTap: () => _carouselController.animateToPage(idx),
                        child: Container(
                          width: _currentCarouselIndex == idx ? 17 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(height / 84.4),
                            color:
                                _currentCarouselIndex == idx
                                    ? const Color.fromARGB(255, 161, 93, 83)
                                    : Colors.teal,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              SizedBox(height: height / 84.4),
              _buildCategorySection(width, height, theme),
              const SizedBox(height: 10),
              _buildItemList(theme, height),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(double width, double height, ThemeData theme) {
    return Align(
      child: Container(
        height: 140,
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          padEnds: false,
          children: [
            _categoryCard(
              'Logistika',
              'assets/category/1_main.jpg',
              LogistMainList(filter: ''),
            ),
            _categoryCard(
              'Awtoulaglar',
              'assets/category/2_main.jpg',
              const MainList(pageName: 'Awtoulaglar', queryName: 'car'),
            ),
            _categoryCard(
              'Hyzmatlar',
              'assets/category/3_main.jpg',
              const MainList(pageName: 'Hyzmatlar', queryName: 'service'),
            ),
            _categoryCard(
              'Elin',
              'assets/category/4_main.png',
              const MainList(pageName: 'Elin hyzmatlar', queryName: 'elin'),
            ),
            _categoryCard(
              'Beylekiler',
              'assets/category/5_main.jpg',
              const MainList(pageName: 'Beýlekiler', queryName: 'other'),
            ),
            _categoryCard(
              'Habarlar',
              'assets/category/6_main.png',
              const NewsMainList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard(String title, String imagePath, Widget route) {
    final double marginHorizontal = MediaQuery.of(context).size.width / 30;
    return InkWell(
      onTap:
          () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
      child: Container(
        width: 100,
        // height: 110,
        // margin: EdgeInsets.symmetric(horizontal: marginHorizontal),
        padding: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover, height: 90, width: 100),

            SizedBox(height: 5),
            CustomText(
              removeHtmlTags(title),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(ThemeData theme, double height) {
    if (_items.isEmpty) {
      return SizedBox(
        height: height / 1.8,
        child: Center(
          child:
              _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Maglumat ýok'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _items[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TopDetailPage(id: item.id, title: item.title),
              ),
            );
          },

          child: Container(
            width: width(context),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.img,
                    width: 100,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 5,
                      right: 10,
                      // bottom: 10,
                    ), // own padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          removeHtmlTags(item.title),
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // biraz uly etmek has okalýar
                          maxLines: 1, // bir setirde görkezmek üçin
                          overflow: TextOverflow.ellipsis,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          removeHtmlTags(item.desc),
                          fontSize: 12,
                          maxLines: 2,
                          color: Theme.of(context).colorScheme.secondary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
