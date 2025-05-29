import 'package:flutter/material.dart';

class SmallText extends StatelessWidget {
  final String text;

  const SmallText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
        fontWeight: FontWeight.w400,
        fontFamily: 'Bricolage',
        fontSize: 10,
      ),
    );
  }
}

class BigText extends StatelessWidget {
  final String text;

  const BigText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontWeight: FontWeight.bold,
        fontFamily: 'Bricolage',
        fontSize: 14,
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomText(
    this.title, {
    super.key,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.black,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
