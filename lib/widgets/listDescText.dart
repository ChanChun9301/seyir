import 'package:flutter/material.dart';
import 'package:seyir/utils/constants.dart';

// ignore: must_be_immutable
class DescTextWidget extends StatelessWidget {
  String? desc;
  DescTextWidget({super.key, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Text(
      removeHtmlTags(desc!),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
        fontWeight: FontWeight.w400,
        fontFamily: 'Bricolage',
        fontSize: 12,
      ),
    );
  }
}
