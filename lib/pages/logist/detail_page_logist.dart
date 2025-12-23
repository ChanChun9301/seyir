import 'package:intl/intl.dart';
import 'package:seyir/api/fetch_logist.dart';
import 'package:seyir/main.dart';
import 'package:seyir/widgets/detail_carousel.dart';
import '/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/widgets/text.dart';
import '../../widgets/circulate_Container.dart';
import '../../component/navbar.dart';
import '/utils/models.dart';
import 'package:url_launcher/url_launcher.dart';

class LogistDetailPage extends StatefulWidget {
  final String id;
  final String title;

  const LogistDetailPage({super.key, required this.id, required this.title});

  @override
  State<LogistDetailPage> createState() => _LogistDetailPageState();
}

class _LogistDetailPageState extends State<LogistDetailPage> {
  late Future<LogistDetailModel> futureCar;
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    futureCar = getLogistDetailApi(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy-MM-dd');
    final today = formatter.format(DateTime.now());

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
      body: FutureBuilder<LogistDetailModel>(
        future: futureCar,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularContainerMain();
          }

          final data = snapshot.data!;
          images = data.images.map((e) => e.url).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                /// Images
                DetailCarouselWidget(images: images),
                const SizedBox(height: 12),

                /// Title + Status
                _card(
                  context,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BigText(text: data.title),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SmallText(text: 'Kategoriýa: ${data.categoryName}'),
                          Row(
                            children: [
                              Text(
                                data.isBring ? 'Getirmeli' : 'Alyp gitmeli',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      data.isBring
                                          ? (SeyirApp.themeNotifier.value ==
                                                  ThemeMode.light
                                              ? Colors.green
                                              : Colors.grey.shade200)
                                          : Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                data.isBring
                                    ? CupertinoIcons.arrow_down_square_fill
                                    : CupertinoIcons.arrow_up_square_fill,
                                size: 18,
                                color:
                                    data.isBring ? Colors.green : Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// Info
                _card(
                  context,
                  Column(
                    children: [
                      _infoRow(Icons.home_work_outlined, data.addressName),
                      _infoRow(Icons.call, data.phone),
                      _infoRow(Icons.price_check_rounded, '${data.price} TMT'),
                    ],
                  ),
                ),

                /// Dates
                _card(
                  context,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallText(text: 'Soňky sene: ${data.lastDate}'),
                      SmallText(
                        text:
                            (data.created).toString().substring(0, 10) == today
                                ? 'Şu gün'
                                : data.created.toString().substring(0, 10),
                      ),
                    ],
                  ),
                ),

                /// Description
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
                      Container(
                        width: width(context),
                        decoration: BoxDecoration(),
                        child: Text(
                          removeHtmlTags(data.desc),
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
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

      /// Call Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () async {
              final uri = Uri(
                scheme: 'tel',
                path: '+993${snapshotPhone(context)}',
              );
              if (await canLaunchUrl(uri)) {
                launchUrl(uri);
              }
            },
            icon: Icon(
              CupertinoIcons.phone,
              size: 16,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            label: Text(
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

  /// Card wrapper
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

  /// Info row
  Widget _infoRow(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(),
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

  /// phone safe getter
  String snapshotPhone(BuildContext context) {
    final state = (context.findAncestorStateOfType<_LogistDetailPageState>());
    return state?.futureCar != null ? '' : '';
  }
}
