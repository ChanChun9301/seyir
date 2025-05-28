// ignore_for_file: file_names, must_be_immutable
import 'dart:developer';
import 'package:flutter/material.dart';

class ImageFullScreen extends StatelessWidget {
  List<dynamic> images = [];
  ImageFullScreen({required this.images, super.key});

  PageController cs = PageController();

  @override
  Widget build(BuildContext context) {
    log(images.toString());
    return Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        body: PageView(
            controller: cs,
            padEnds: false,
            children: images
                .map(
                  (e) => e != ''
                      ? ImageContainer(image: e)
                      : const Center(
                          child: Text(
                          'Surat yok',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                )
                .toList()));
  }
}

class ImageContainer extends StatelessWidget {
  const ImageContainer({
    super.key,
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          child: Image.network(
            image,
            fit: BoxFit.fitWidth,
          ),
        ));
  }
}
