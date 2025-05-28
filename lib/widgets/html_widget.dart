// import 'package:html_unescape/html_unescape.dart';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

// ignore: must_be_immutable
class HtmlWidget extends StatelessWidget {
  String text = '';
  HtmlWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: text,
      style: {
        "p": Style(
          color: Theme.of(context).colorScheme.onSecondary,
        ),
        "li": Style(
          color: Theme.of(context).colorScheme.onSecondary,
        ),
        "h1": Style(
          color: Theme.of(context).colorScheme.onSecondary,
        ),
        "a": Style(
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      },
    );
  }
}
