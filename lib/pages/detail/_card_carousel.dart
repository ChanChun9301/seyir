import 'package:flutter/material.dart';
import '/utils/constants.dart';

class CarouselItemcard extends StatelessWidget {
  const CarouselItemcard({
    super.key,
    required this.context,
    required this.child,
  });

  final BuildContext context;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width(context),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
