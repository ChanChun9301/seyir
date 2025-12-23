import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:seyir/utils/constants.dart';
import 'package:seyir/widgets/images.dart';

@immutable
class DetailCarouselWidget extends StatefulWidget {
  final List<String> images;
  const DetailCarouselWidget({super.key, required this.images});

  @override
  State<DetailCarouselWidget> createState() => _DetailCarouselWidgetState();
}

class _DetailCarouselWidgetState extends State<DetailCarouselWidget> {
  final CarouselSliderController csc = CarouselSliderController();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(height(context) / 84.4),
      child: Column(
        children: [
          widget.images.isNotEmpty
              ? CarouselSlider(
                items:
                    widget.images
                        .asMap()
                        .entries
                        .map(
                          (e) => Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(height(context) / 84.4),
                              ),
                              child: Images(images: widget.images, id: e.key),
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
                          currentIndex = index;
                        }),
                      },
                ),
              )
              : Container(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(height(context) / 84.4),
                  ),
                  child: Image.asset(
                    'assets/no-image.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                widget.images.asMap().entries.map((entry) {
                  int index = entry.key;
                  return GestureDetector(
                    onTap: () => csc.animateToPage(index),
                    child: Container(
                      width: currentIndex == index ? 17 : 7,
                      height: 7.0,
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          height(context) / 84.4,
                        ),
                        color:
                            currentIndex == index
                                ? const Color.fromARGB(255, 161, 93, 83)
                                : Colors.teal,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
