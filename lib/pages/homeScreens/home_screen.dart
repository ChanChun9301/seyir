import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../component/navbar.dart';
import '../../utils/constants.dart';
import '../../utils/models.dart';

import '../controls/carousel_control.dart';
import '../lists/main_list.dart';
import '../logist/logist_main_list.dart';
import '../spare/spare_list.dart';
import '../top/top_detailpage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
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
    _backButtonTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
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
        Uri.parse('$baseUrl/top-products/?checked=True&page=$_currentPage'),
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
        const SnackBar(
          content: Text('Ýene bir gezek basyň çykmak üçin!'),
          duration: Duration(seconds: 2),
        ),
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 10,
            centerTitle: true,
            title: Text(
              'Seýir',
              style: const TextStyle(
                // fontStyle: FontStyle.italic,
                letterSpacing: 2,
                fontFamily: "Bricolage",
                fontSize: 16,
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

            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
        ),
        drawer: const NavBar(),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          backgroundColor: theme.colorScheme.primary,
          color: Colors.white,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // === AppBar + Carousel ===
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: kToolbarHeight - 20),
                    _buildModernCarousel(height, theme),
                    const SizedBox(height: 16),
                    _buildCarouselDots(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // === Categories ===
              SliverToBoxAdapter(child: _buildModernCategories(theme)),
              // const SliverToBoxAdapter(   child: SizedBox(height: 24)),

              // === Items List ===
              _items.isEmpty && !_isLoading
                  ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Maglumat ýok',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    sliver: SliverList.separated(
                      itemCount: _items.length + (_hasMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == _items.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return _buildModernItemCard(_items[index], theme);
                      },
                    ),
                  ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  // === КАРУСЕЛЬ ===
  Widget _buildModernCarousel(double height, ThemeData theme) {
    return Obx(() {
      final items = _carouselControl.carouselItems;
      if (items.isEmpty) {
        return Container(
          height: height * 0.25,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: theme.colorScheme.primaryContainer,
          ),
          child: const Center(child: Icon(Icons.image, size: 50)),
        );
      }

      return CarouselSlider.builder(
        itemCount: items.length,
        carouselController: _carouselController,
        options: CarouselOptions(
          height: height * 0.25,
          autoPlay: true,
          viewportFraction: 0.88,
          enlargeCenterPage: true,
          aspectRatio: 16 / 9,
          onPageChanged: (i, _) => setState(() => _currentCarouselIndex = i),
        ),
        itemBuilder: (context, index, _) {
          final item = items[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.img,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Image.asset(
                          'assets/no-image.jpg',
                          fit: BoxFit.cover,
                        ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Text(
                      removeHtmlTags(item.name ?? ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // === ТОЧКИ КАРУСЕЛИ ===
  Widget _buildCarouselDots() {
    return Obx(() {
      final items = _carouselControl.carouselItems;
      if (items.isEmpty) return const SizedBox();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            items.asMap().entries.map((e) {
              final idx = e.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentCarouselIndex == idx ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color:
                      _currentCarouselIndex == idx
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
      );
    });
  }

  // === КАТЕГОРИИ ===
  Widget _buildModernCategories(ThemeData theme) {
    final categories = [
      _cat(
        'Logistika',
        'assets/category/1_main.jpg',
        LogistMainList(filter: ''),
      ),
      _cat(
        'Awtoulaglar',
        'assets/category/2_main.jpg',
        MainList(pageName: 'Awtoulaglar', queryName: 'car', filter: ''),
      ),
      _cat(
        'Awto şaýlary',
        'assets/category/6_main.png',
        SpareMainList(filter: ''),
      ),
      _cat(
        'Hyzmatlar',
        'assets/category/3_main.jpg',
        MainList(pageName: 'Hyzmatlar', filter: '', queryName: 'hyzmatlar'),
      ),
    ];

    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            categories.map((cat) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => cat['route']),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: theme.colorScheme.primaryContainer,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.asset(
                          cat['image'],
                          height: 60,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          cat['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Bricolage',
                            fontSize: 12,
                            color: theme.colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Map<String, dynamic> _cat(String title, String img, Widget route) => {
    'title': title,
    'image': img,
    'route': route,
  };

  // === КАРТОЧКА ЭЛЕМЕНТА ===
  Widget _buildModernItemCard(PageModel item, ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopDetailPage(id: item.id, title: item.title),
            ),
          ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'item-${item.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.img,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    removeHtmlTags(item.title),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                      fontSize: 15,
                      fontFamily: 'Bricolage',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    removeHtmlTags(item.desc),
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontFamily: 'Bricolage',
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(item.created.toString()),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.secondary,
                          fontFamily: 'Bricolage',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'Näbelli';
    try {
      final d = DateTime.parse(date);
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inDays > 0) return '${diff.inDays} gün öň';
      if (diff.inHours > 0) return '${diff.inHours} sagat öň';
      if (diff.inMinutes > 0) return '${diff.inMinutes} minut öň';
      return 'Şu wagt';
    } catch (e) {
      return 'Näbelli';
    }
  }
}
