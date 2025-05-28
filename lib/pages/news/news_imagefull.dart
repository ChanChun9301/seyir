// ignore_for_file: file_names

import 'package:flutter/material.dart';

class NewsImageFullScreen extends StatefulWidget {
  final String img;
  const NewsImageFullScreen({required this.img, super.key});

  @override
  State<NewsImageFullScreen> createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<NewsImageFullScreen> {
  PageController cs = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon:const Icon(
                  Icons.arrow_back_outlined,
                  color: Colors.white,
                  size: 22,
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
          children: [
            widget.img != ''
                ? ImageContainer(widget: widget.img)
                : const Center(
                    child: Text(
                    'Surat yok',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  )),
          ],
        ));
  }
}

class ImageContainer extends StatelessWidget {
  const ImageContainer({
    super.key,
    required this.widget,
  });

  final String widget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          child: Image.network(
            widget,
            fit: BoxFit.fitWidth,
          ),
        ));
  }
}
