import 'package:flutter/material.dart';
import 'package:seyir/component/image_full.dart';

class Images extends StatelessWidget {
  const Images({
    super.key,
    required this.images,
    required this.id,
  });

  final List<String> images;

  final int id;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ImageFullScreen(images: images)));
        },
        child: Image.network(
          images[id],
          fit: BoxFit.fill,
        ));
  }
}
